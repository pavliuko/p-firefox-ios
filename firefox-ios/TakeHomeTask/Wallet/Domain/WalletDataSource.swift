// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Web3Core
import web3swift
import Foundation

// MARK: Model
struct WalletMetadata: Codable, Hashable {
    let name: String
    let address: String
}

// MARK: WalletDataSource
class WalletDataSource {
    // MARK: Constants
    enum C {
        static let keystore = "keystore"
        static let dotJson = ".json"
        static let walletsMetadata = "walletsMetadata.json"
    }

    // MARK: Error
    enum Error: Swift.Error {
        case userDirectoryNotFound
        case failedToCreateDirectory
        case failedToCreateFile
    }

    // MARK: Interface
    func storeWallet(
        _ keystore: BIP32Keystore,
        address: String,
        userRepresentationName: String
    ) throws {
        try add(keystore: keystore, fileName: address)
        try addWalletMetadata(.init(name: userRepresentationName, address: address))
    }

    func retrieveExistingWalletsMetadata() throws -> [WalletMetadata] {
        try loadWalletMetadata()
    }
}

// MARK: Store wallet data
private extension WalletDataSource {
    func add(keystore: BIP32Keystore, fileName: String) throws {
        let data = try JSONEncoder().encode(keystore.keystoreParams)
        let directoryPath = try WalletDataSource.dedicatedKeystoreDirPath()
        let filePath = directoryPath + "/" + fileName + C.dotJson
        FileManager.default.createFile(
            atPath: filePath,
            contents: data
        )
    }
}

// MARK: Manipulate with wallet metadata
private extension WalletDataSource {
    func loadWalletMetadata() throws -> [WalletMetadata] {
        // Get the file URL
        let fileURL = try Self.walletsMetadataFilePath()

        let data = try Data(contentsOf: fileURL)

        let walletUsers = try JSONDecoder().decode(
            [WalletMetadata].self,
            from: data
        )

        return walletUsers
    }

    func addWalletMetadata(_ newUser: WalletMetadata) throws {
        var walletUsers = try loadWalletMetadata()
        walletUsers.append(newUser)
        let data = try JSONEncoder().encode(walletUsers)

        let fileURL = try Self.walletsMetadataFilePath()

        try data.write(to: fileURL, options: [.atomicWrite])
    }
}

// MARK: File management
extension WalletDataSource {
    static func dedicatedKeystoreDirPath() throws -> String {
        let fileManager = FileManager.default

        guard let userDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw Error.userDirectoryNotFound
        }

        let keystoreDir = userDir.appendingPathComponent(C.keystore)

        try createDirectoryIfNeeded(at: keystoreDir)

        return keystoreDir.path
    }

    private static func walletsMetadataFilePath() throws -> URL {
        let fileManager = FileManager.default

        guard let userDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw Error.userDirectoryNotFound
        }

        let keystoreDir = userDir.appendingPathComponent(C.keystore)
        let keyFilePath = keystoreDir.appendingPathComponent(C.walletsMetadata)

        try createDirectoryIfNeeded(at: keystoreDir)
        try createFileIfNeeded(at: keyFilePath)

        return keyFilePath
    }

    static func createDirectoryIfNeeded(at url: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                throw Error.failedToCreateDirectory
            }
        }
    }

    static func createFileIfNeeded(at url: URL) throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            let fileContent = "[]"
            do {
                try fileContent.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                throw Error.failedToCreateFile
            }
        }
    }
}
