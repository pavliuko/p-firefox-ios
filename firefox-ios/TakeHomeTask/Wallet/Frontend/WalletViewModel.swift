// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import BigInt
import SwiftUI
import Web3Core
import web3swift

struct SendETHRequest {
    enum State {
        case idle
        case triggered
        case inProgress
        case success
        case fail
    }

    var recipient: String = .init()
    var amount: String = .init()
    var password: String = .init()
    var state: State = .idle

    var isStarted: Bool {
        switch state {
        case .idle:
            return false
        default:
            return true
        }
    }

    var isSendingInProgress: Bool {
        switch state {
        case .inProgress:
            return true
        default:
            return false
        }
    }
}

struct WalletState {
    enum BalanceRequestState {
        case inProgress
        case success(String)
        case failed

        var isCompleted: Bool {
            switch self {
            case .failed,
                 .success:
                return true
            case .inProgress:
                return false
            }
        }

        var balance: String {
            switch self {
            case let .success(value):
                return value
            default:
                return .init()
            }
        }

        var value: String {
            if balance.isEmpty {
                return .init()
            } else {
                return "\(balance) ETH"
            }
        }
    }

    let name: String
    let address: String
    let link: URL?
    var balanceRequestState: BalanceRequestState = .inProgress
    var sendETHRequest: SendETHRequest = .init()

    var isSendETHRequestValid: Bool {
        guard !sendETHRequest.recipient.isEmpty else {
            return false
        }

        guard let amount = Double(sendETHRequest.amount) else {
            return false
        }

        guard let balance = Double(balanceRequestState.balance) else {
            return false
        }

        return amount <= balance
    }
}

@MainActor
class WalletViewModel: ObservableObject {
    enum Error: Swift.Error {
        case sendingETHFailed
    }

    @Published var state: WalletState

    private let walletService: Web3Service

    init(
        wallet: WalletMetadata,
        walletService: Web3Service = .init()
    ) {
        let url = URL(string: "https://etherscan.io/address/\(wallet.address)")
        state = .init(
            name: wallet.name,
            address: wallet.address,
            link: url
        )
        self.walletService = walletService
    }

    func getBalance() async {
        guard let ethAddress = walletService.retrieveEthereumAddressBy(
            address: state.address
        ) else {
            state.balanceRequestState = .failed
            return
        }
        Task.detached {
            guard let balance = try? await Web3.InfuraMainnetWeb3().eth.getBalance(for:
                ethAddress)
            else {
                await MainActor.run {
                    self.state.balanceRequestState = .failed
                }
                return
            }
            let balanceString = Utilities.formatToPrecision(balance)

            await MainActor.run {
                self.state.balanceRequestState = .success(balanceString)
            }
        }
    }

    func startSendingRequest() {
        state.sendETHRequest.state = .triggered
    }

    func send() async {
        state.sendETHRequest.state = .inProgress
        do {
            let result = try await walletService.send(
                address: state.address,
                recipient: state.sendETHRequest.recipient,
                password: state.sendETHRequest.password,
                amount: state.sendETHRequest.amount
            )
            print(result)
            state.sendETHRequest.state = .success
        } catch {
            print(error)
            state.sendETHRequest.state = .fail
        }
    }
}
