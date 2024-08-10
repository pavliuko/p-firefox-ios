// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct WalletView: View {
    @ObservedObject var vm: WalletViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Wallet")
        }
        .padding()
    }
}
