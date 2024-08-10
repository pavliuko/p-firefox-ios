// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct WalletsHomeState {
    var wallets: [WalletMetadata] = .init()
    var error: Error? = .none
}

@MainActor
class WalletsHomeViewModel: ObservableObject {
    @Published var state: WalletsHomeState

    private let walletDataSource: WalletDataSource

    init(
        state: WalletsHomeState = .init(),
        walletDataSource: WalletDataSource = .init()
    ) {
        self.state = state
        self.walletDataSource = walletDataSource
    }

    func loadData() {
        do {
            state.wallets = try walletDataSource.retrieveExistingWalletsMetadata()
            state.error = .none
        } catch {
            state.error = error
            state.wallets = []
        }
    }
}
