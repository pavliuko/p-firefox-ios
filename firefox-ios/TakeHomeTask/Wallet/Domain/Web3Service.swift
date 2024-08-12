// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import BigInt
import Web3Core
import web3swift
import Foundation

struct WalletComponents {
    let address: String?
    let mnemonics: String?
}

enum KeySettings {
    enum DerivationPaths: String {
        case ethereum = "m/44'/60'/0'/0"
        case ropsten = "m/44'/1'/0'/0"

        static var forCurrentEnvironment: DerivationPaths {
            #if DEBUG
                return .ethereum
            #else
                return .ethereum
            #endif
        }
    }
}

class Web3Service {
    enum Error: Swift.Error {
        case failedToGenerateMnemonics
        case failedToCreateWallet
        case failedToGetAddress
        case failedToGetEntropy
        case failedToStoreWallet(Swift.Error)
        case failedToSendETH
    }

    private let dataSource: WalletDataSource

    init(dataSource: WalletDataSource = WalletDataSource()) {
        self.dataSource = dataSource
    }

    func createWallet(
        name: String,
        passphrase: String,
        derivationPath: KeySettings.DerivationPaths = .forCurrentEnvironment,
        bitsOfEntropy: Int = 256
    ) throws -> WalletComponents {
        guard let mnemonics = try BIP39.generateMnemonics(
            bitsOfEntropy: bitsOfEntropy,
            language: .english
        ) else {
            throw Error.failedToGenerateMnemonics
        }

        guard let walletAddress = try? BIP32Keystore(
            mnemonics: mnemonics,
            password: passphrase,
            prefixPath: derivationPath.rawValue
        ) else {
            throw Error.failedToCreateWallet
        }

        guard let address = walletAddress.addresses?.first?.address else {
            throw Error.failedToGetAddress
        }

        try dataSource.storeWallet(walletAddress, address: address, userRepresentationName: name)

        return WalletComponents(address: address, mnemonics: mnemonics)
    }

    func send(
        address: String,
        recipient: String,
        password: String,
        amount: String
    ) async throws -> TransactionSendingResult {
        let web3 = try await Web3.InfuraMainnetWeb3()
        guard
            let toAddress = EthereumAddress(recipient),
            let ethAddress = retrieveEthereumAddressBy(address: address),
            let amount = Double(amount),
            let privateKey = privateKey(
                address: address,
                password: password
            )
        else {
            throw Error.failedToSendETH
        }

        let bigInAmount = BigUInt(amount * pow(10, 18))
        var transaction: CodableTransaction = .emptyTransaction
        transaction.from = ethAddress
        transaction.to = toAddress
        transaction.value = bigInAmount
        transaction.gasLimit = 78423
        transaction.gasPrice = 20_000_000_000
        transaction.chainID = 1

        let pendingNonce = try await web3.eth.getTransactionCount(
            for: ethAddress,
            onBlock: .pending
        )
        let latestNonce = try await web3.eth.getTransactionCount(for: ethAddress, onBlock: .latest)
        let selectedNonce = max(pendingNonce, latestNonce)

        transaction.nonce = selectedNonce
        try transaction.sign(privateKey: privateKey)

        guard let transactiondata: Data = transaction.encode() else {
            throw Error.failedToSendETH
        }

        return try await web3.eth.send(raw: transactiondata)
    }

    func retrieveEthereumAddressBy(address: String) -> EthereumAddress? {
        try? KeystoreManager.dedicated().addresses?.first { $0.address == address }
    }

    private func privateKey(address: String, password: String) -> Data? {
        if let address = retrieveEthereumAddressBy(address: address),
           let privateKey = try? KeystoreManager.dedicated().UNSAFE_getPrivateKeyData(
               password: password,
               account: address
           ) {
            return privateKey
        }

        return nil
    }
}
