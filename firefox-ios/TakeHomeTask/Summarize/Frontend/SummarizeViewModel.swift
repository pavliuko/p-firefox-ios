// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI
import Combine

struct SummarizeState {
    enum ModelDownloading {
        case inProgress(progress: CGFloat)
        case done
    }

    var modelDownloadingState: ModelDownloading = .inProgress(progress: 0)
    var inProgress: Bool = false
    var summary: String? = .none
}

@MainActor
class SummarizeViewModel: ObservableObject {
    @Published var state: SummarizeState
    @Published var llm: LLMClient?

    private var cancellable: AnyCancellable?
    let source: String

    init(state: SummarizeState = .init(), source: String) {
        self.state = state
        self.source = source
    }

    func start() async {
        let llm = await LLMClient { [weak self] progress in
            self?.setLLMModelDownloadProgress(progress: progress)
        }
        setLLMModelDownloadingDone()

        await MainActor.run {
            self.llm = llm
            self.cancellable = self.llm?.$output
                .sink(
                    receiveValue: { [weak self] newOutput in
                        self?.state.summary = newOutput
                    }
                )
        }

        setLLMSummaryRequestedState()
        await self.llm?.respond(to: source)
        setLLMModelRespond()
    }

    func stop() {
        llm?.stop()
    }

    deinit {
        cancellable?.cancel()
    }
}

private extension SummarizeViewModel {
    @MainActor
    func setLLMModelDownloadProgress(progress: Double) {
        state.modelDownloadingState = .inProgress(progress: CGFloat(progress))
    }

    @MainActor
    func setLLMModelDownloadingDone() {
        state.modelDownloadingState = .done
    }

    @MainActor
    func setLLMSummaryRequestedState() {
        state.inProgress = true
    }

    @MainActor
    func setLLMModelRespond() {
        state.inProgress = false
    }
}
