// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct WalletsHomeView: View {
    @ObservedObject var vm: WalletsHomeViewModel
    private let callback: (URL?) -> Void

    var body: some View {
        List {
            Section {
                if vm.state.wallets.isEmpty {
                    HStack {
                        Image(systemName: "wallet.pass")
                        Text("No wallets found")
                    }

                } else {
                    ForEach(vm.state.wallets, id: \.self) { wallet in
                        NavigationLink {
                            WalletView(vm: .init(wallet: wallet), callback: callback)
                        } label: {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                Text(wallet.name)
                            }
                        }
                    }
                }
            } header: {
                Text("Existing wallets")
            }
            Section {
                NavigationLink {
                    CreateWalletView(vm: .init())
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Create new wallet")
                    }
                }

            } header: {
                Text("Actions")
            }
        }
        .onAppear {
            vm.loadData()
        }
    }
}

// MARK: - Wallets Home wrapped with Navigation View
extension WalletsHomeView {
    static func walletsHomeViewWithNavigation(
        vm: WalletsHomeViewModel,
        callback: @escaping (URL?) -> Void
    ) -> some View {
        NavigationView {
            WalletsHomeView(vm: vm, callback: callback)
        }
        .navigationViewStyle(.stack)
    }
}

#Preview {
    WalletsHomeView.walletsHomeViewWithNavigation(
        vm: .init(
            state: .init(
                wallets: [
                    .init(
                        name: "Wallet #1",
                        address: "Address # 1"
                    ),
                ]
            )
        ),
        callback: { _ in }
    )
}
