// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import LLM
import Foundation

class LLMClient: LLM {
    convenience init?(_ update: @escaping (Double) -> Void) async {
        let systemPrompt = "Can you explain what this website is? Up to 50 words in length."
        let model = HuggingFaceModel(
            "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF",
            .Q2_K,
            template: .chatML(systemPrompt)
        )
        try? await self.init(
            from: model,
            as: "tinyllama-1.1b-chat-v1.0.Q2_K.gguf"
        ) { progress in
            update(progress)
        }
    }
}
