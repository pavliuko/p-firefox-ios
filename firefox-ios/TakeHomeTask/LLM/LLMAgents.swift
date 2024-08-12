// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import LLM
import Foundation

final class SummarizeWebPageLLMAgent: LLM {
    convenience init(progressCallback: @escaping (Double) -> Void) async throws {
        try await self.init(
            from: .init(
                "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF",
                .Q3_K_S,
                template: .chatML("Can you explain what this website is? Up to 50 words in length.")
            ),
            as: "tinyllama-1.1b-chat-v1.0.Q4_K_S.gguf",
            maxTokenCount: 1024,
            updateProgress: progressCallback
        )
    }
}

final class WindowAILLMAgent: LLM {
    convenience init(
        systemPrompt: String,
        progressCallback: @escaping (Double) -> Void
    ) async throws {
        try await self.init(
            from: .init(
                "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF",
                .Q4_K_M,
                template: .chatML(systemPrompt)
            ),
            as: "tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf",
            maxTokenCount: 1024,
            updateProgress: progressCallback
        )
    }

    @MainActor
    class func make(
        systemPrompt: String,
        progressCallback: @escaping (Double) -> Void
    ) async throws -> WindowAILLMAgent {
        try await WindowAILLMAgent(
            systemPrompt: systemPrompt,
            progressCallback: progressCallback
        )
    }

    @MainActor
    func process(prompt: String) async -> String? {
        await respond(to: prompt)
        return output
    }
}
