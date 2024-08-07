// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

struct SummarizeView: View {
    @ObservedObject var vm: SummarizeViewModel

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text("Hello, Puma User!")
                .font(.title2)
            if case let .inProgress(value) = vm.state.modelDownloadingState {
                Text("Model is loading, please wait...")
                    .font(.title3)
                ProgressView(
                    value: value,
                    label: { EmptyView() },
                    currentValueLabel: {
                        Text(
                            String(format: "%.2f%%", value * 100)
                        )
                    }
                )
            } else if vm.state.inProgress {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Generating summary now. Stay tuned...")
                }
            } else {
                Text("Here is the summary for you:")
            }

            if let summary = vm.state.summary {
                if #available(iOS 16.4, *) {
                    Text(summary)
                        .monospaced()
                } else {
                    Text(summary)
                }
            }

            Spacer()
        }
        .padding()
        .task {
            await vm.start()
        }
    }

    func stop() {
        vm.stop()
    }
}
