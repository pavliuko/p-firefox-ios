// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import UIKit
import SwiftUI
import ComponentLibrary

class SummarizeCoordinator: BaseCoordinator {
    private let profile: Profile

    init(router: Router, profile: Profile) {
        self.profile = profile
        super.init(router: router)
    }

    @MainActor
    func showSummarizeView() {
        let view = SummarizeView()

        let viewController = SelfSizingHostingController(rootView: view)

        var bottomSheetViewModel = BottomSheetViewModel(
            closeButtonA11yLabel: .CloseButtonTitle,
            closeButtonA11yIdentifier: AccessibilityIdentifiers.EnhancedTrackingProtection.MainScreen.closeButton
        )
        bottomSheetViewModel.shouldDismissForTapOutside = false

        let bottomSheetVC = BottomSheetViewController(
            viewModel: bottomSheetViewModel,
            childViewController: viewController
        )
        router.present(bottomSheetVC)
    }
}
