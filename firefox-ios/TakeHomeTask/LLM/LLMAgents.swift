// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import LLM
import Foundation

final class SummarizeWebPageLLMAgent: LLM {
    convenience init(updateCallback: @escaping (Double) -> Void) async throws {
        try await self.init(
            from: .init(
                "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF",
                .Q2_K,
                template: .chatML("Can you explain what this website is? Up to 50 words in length.")
            ),
            as: "tinyllama-1.1b-chat-v1.0.Q2_K.gguf",
            maxTokenCount: 1024,
            updateProgress: updateCallback
        )
    }
}

final class WindowAILLMAgent: LLM {
    convenience init(
        systemPrompt: String,
        updateCallback: @escaping (Double) -> Void
    ) async throws {
        try await self.init(
            from: .init(
                "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF",
                .Q4_K_M,
                template: .chatML(systemPrompt)
            ),
            as: "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
            maxTokenCount: 1024,
            updateProgress: updateCallback
        )
    }
}
