// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Web3Core
import web3swift
import Foundation

// MARK: KeystoreManager
extension KeystoreManager {
    enum DedicatedKeystoreManagerError: Swift.Error {
        case failedToInitialize
    }

    static func dedicated() throws -> KeystoreManager {
        let path = try WalletDataSource.dedicatedKeystoreDirPath()

        guard let manager = KeystoreManager.managerForPath(path, scanForHDwallets: true) else {
            throw DedicatedKeystoreManagerError.failedToInitialize
        }

        return manager
    }
}
