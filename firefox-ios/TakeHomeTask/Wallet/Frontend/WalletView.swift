// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct WalletView: View {
    enum FocusedField {
        case recipient
        case amount
        case password
    }

    @ObservedObject var vm: WalletViewModel
    @Environment(\.dismiss) var dismiss
    let callback: (URL?) -> Void

    @FocusState var focusedField: FocusedField?

    var body: some View {
        ZStack {
            List {
                walletSection
                detailsSection
                etherscanSection
                actionOrPasswordSection
            }
            .listStyle(InsetGroupedListStyle())

            if vm.state.sendETHRequest.isStarted {
                VStack {
                    Spacer()
                    confirmButton
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
        }
        .onAppear {
            focusedField = .recipient
        }
        .task {
            await vm.getBalance()
        }
    }

    // MARK: - Sections

    private var walletSection: some View {
        Section(
            header: Text(vm.state.sendETHRequest.isStarted ? "From" : "Wallet")
        ) {
            walletInfoRow
            if vm.state.sendETHRequest.isStarted {
                balanceRow
            }
        }
    }

    private var detailsSection: some View {
        Section(
            header: Text(vm.state.sendETHRequest.isStarted ? "To" : "Balance")
        ) {
            if vm.state.sendETHRequest.isStarted {
                recipientRow
                amountRow
            } else {
                balanceRow
            }
        }
    }

    private var etherscanSection: some View {
        Group {
            if !vm.state.sendETHRequest.isStarted {
                Section(
                    header: Text("View on Etherscan")
                ) {
                    etherscanRow
                }
            }
        }
    }

    private var actionOrPasswordSection: some View {
        Section(
            header: Text(vm.state.sendETHRequest
                .isStarted ? "Password" : "Actions")
        ) {
            if vm.state.sendETHRequest.isStarted {
                passwordRow
            } else {
                sendETHRow
            }
        }
    }

    // MARK: - Rows

    private var walletInfoRow: some View {
        HStack {
            Image(systemName: "diamond.bottomhalf.filled")
            VStack(alignment: .leading) {
                if !vm.state.sendETHRequest.isStarted {
                    Text(vm.state.name)
                        .lineLimit(1)
                }
                Text(vm.state.address)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            copyButton
        }
    }

    private var copyButton: some View {
        Button(action: {
            UIPasteboard.general.string = vm.state.address
        }) {
            Image(systemName: "doc.on.doc")
        }
    }

    private var balanceRow: some View {
        Group {
            if vm.state.balanceRequestState.isCompleted {
                Text(vm.state.balanceRequestState.value)
            } else {
                ProgressView()
            }
        }
    }

    private var etherscanRow: some View {
        Group {
            Button(
                action: {
                    callback(vm.state.link)
                }
            ) {
                Text("etherscan.io")
                    .foregroundColor(.blue)
            }
        }
    }

    private var recipientRow: some View {
        TextField("Recipient address", text: $vm.state.sendETHRequest.recipient)
            .focused($focusedField, equals: .recipient)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }

    private var amountRow: some View {
        TextField("Amount", text: $vm.state.sendETHRequest.amount)
            .focused($focusedField, equals: .amount)
            .keyboardType(.decimalPad)
    }

    private var passwordRow: some View {
        SecureField("Password", text: $vm.state.sendETHRequest.password)
            .focused($focusedField, equals: .password)
    }

    private var sendETHRow: some View {
        HStack {
            VStack {
                sendETHButton
                Text("Send ETH")
                    .monospaced()
                    .foregroundColor(!vm.state.balanceRequestState.isCompleted ? .gray : .blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var sendETHButton: some View {
        Button(
            action: {
                withAnimation {
                    vm.startSendingRequest()
                }
            }, label: {
                Image(systemName: "arrow.up.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        )
        .disabled(!vm.state.balanceRequestState.isCompleted)
    }

    private var confirmButton: some View {
        let title: String
        let color: Color
        switch vm.state.sendETHRequest.state {
        case .idle,
             .inProgress,
             .triggered:
            title = "Confirm"
            color = .blue
        case .success:
            title = "Success"
            color = .green
        case .fail:
            title = "Failed"
            color = .red
        }

        return Button(
            action: {
                switch vm.state.sendETHRequest.state {
                case .idle,
                     .inProgress,
                     .triggered:
                    Task {
                        await vm.send()
                    }
                case .fail,
                     .success:
                    dismiss()
                }
            }, label: {
                HStack(spacing: 10) {
                    if vm.state.sendETHRequest.isSendingInProgress {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(title)
                }
            }
        )
        .tint(color)
        .disabled(!vm.state.balanceRequestState.isCompleted || !vm.state.isSendETHRequestValid)
    }
}

#Preview {
    WalletView(
        vm: .init(wallet: .init(name: "Name", address: "0xadress")),
        callback: { _ in }
    )
}
