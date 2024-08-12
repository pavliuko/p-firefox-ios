// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Web3Core
import web3swift

struct CreateWalletState {
    var name: String
    var password: String
    var walletComponents: WalletComponents?
    var error: Error?

    var isGenerated: Bool {
        walletComponents != nil &&
            walletComponents?.address != nil &&
            walletComponents?.mnemonics != nil
    }

    var address: String? {
        walletComponents?.address
    }

    var mnemonics: String? {
        walletComponents?.mnemonics
    }

    init(
        name: String = "My New Wallet",
        passphrase: String = .init(),
        generatedContent: WalletComponents? = .none,
        error: Error? = .none
    ) {
        self.name = name
        password = passphrase
        walletComponents = generatedContent
        self.error = error
    }
}

@MainActor
class CreateWalletViewModel: ObservableObject {
    @Published var state: CreateWalletState

    private let web3Service: Web3Service

    init(
        state: CreateWalletState = .init(),
        web3Service: Web3Service = Web3Service()
    ) {
        self.state = state
        self.web3Service = web3Service
    }

    func createWallet() {
        do {
            state.walletComponents = try web3Service.createWallet(
                name: state.name,
                passphrase: state.password
            )
            state.error = .none
        } catch {
            state.error = error
        }
    }
}

struct CreateWalletView: View {
    enum FocusedField {
        case name
        case passphrase
    }

    @ObservedObject var vm: CreateWalletViewModel
    @FocusState private var focusedField: FocusedField?

    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            List {
                Section {
                    Group {
                        TextField("Wallet Name", text: $vm.state.name)
                            .focused($focusedField, equals: .name)
                        SecureField("Password", text: $vm.state.password)
                            .focused($focusedField, equals: .passphrase)
                    }
                    .disabled(vm.state.isGenerated)
                } header: {
                    Text("New wallet")
                }
                if let address = vm.state.address {
                    Section {
                        HStack {
                            Text(address)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(
                                action: {
                                    UIPasteboard.general.string = vm.state.walletComponents?.address
                                }, label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            )
                            .frame(width: 30, alignment: .trailing)
                        }
                    } header: {
                        Text("New wallet with address")
                    }
                }

                if let mnemonics = vm.state.mnemonics {
                    Section {
                        HStack {
                            Text(mnemonics)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Button(
                                action: {
                                    UIPasteboard.general.string = vm.state.walletComponents?
                                        .mnemonics
                                }, label: {
                                    Image(systemName: "doc.on.doc")
                                }
                            )
                            .frame(width: 30, alignment: .trailing)
                        }
                    } header: {
                        Text("Your words are")
                    }
                }
            }
            VStack {
                Spacer()
                Button(vm.state.isGenerated ? "Done" : "Create Wallet") {
                    if vm.state.isGenerated {
                        dismiss()
                    } else {
                        vm.createWallet()
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            }
        }
        .onAppear {
            focusedField = .passphrase
        }
        .onDisappear {
            vm.state = .init()
        }
    }
}

#Preview {
    CreateWalletView(
        vm: .init(state: CreateWalletState(
            name: "SSD",
            passphrase: "sda",
            generatedContent: .init(
                address: "asdads",
                mnemonics: "adas asdas asdaadas asdas asdaadas asdas asdaadas asdas asdaadas asdas asdaadas asdas asdaadas asdas asda"
            )
        ))
    )
}
