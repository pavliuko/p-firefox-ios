// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import SwiftUI
import ComponentLibrary

class WalletCoordinator: BaseCoordinator {
    init(router: Router) {
        super.init(router: router)
    }

    @MainActor
    func showWalletView() {
        let view = WalletView(vm: WalletViewModel())

        let viewController = UIHostingController(rootView: view)

        router.present(viewController)
    }
}
