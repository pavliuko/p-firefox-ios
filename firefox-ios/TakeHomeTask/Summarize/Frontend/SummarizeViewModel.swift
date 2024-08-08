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
    var summary: String = .init()
}

@MainActor
class SummarizeViewModel: ObservableObject {
    @Published var state: SummarizeState
    @Published var llm: SummarizeWebPageLLMAgent?

    let source: String

    init(state: SummarizeState = .init(), source: String) {
        self.state = state
        self.source = source
    }

    @MainActor
    func start() async {
        do {
            llm = try await SummarizeWebPageLLMAgent { progress in
                Task { @MainActor [weak self] in
                    self?.setLLMModelDownloadProgress(progress: progress)
                }
            }
            llm?.update = { delta in
                Task { @MainActor [weak self] in
                    self?.updateSummary(with: delta)
                }
            }
            setLLMModelDownloadingDone()

            setLLMSummaryRequestedState()

            await llm?.respond(to: source)

            setLLMModelRespond()
        } catch {
            print("Failed to start LLM agent: \(error)")
        }
    }

    func stop() {
        llm?.stop()
    }
}

private extension SummarizeViewModel {
    func setLLMModelDownloadProgress(progress: Double) {
        state.modelDownloadingState = .inProgress(progress: CGFloat(progress))
    }

    func setLLMModelDownloadingDone() {
        state.modelDownloadingState = .done
    }

    func setLLMSummaryRequestedState() {
        state.inProgress = true
        state.summary = .init()
    }

    func setLLMModelRespond() {
        state.inProgress = false
    }

    func updateSummary(with delta: String?) {
        let delta = delta ?? .init()
        state.summary += delta
    }
}
