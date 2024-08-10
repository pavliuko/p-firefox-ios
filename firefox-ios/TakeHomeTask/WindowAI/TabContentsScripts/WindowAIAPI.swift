// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import WebKit

// swiftlint:disable line_length
final class WindowAIAPI: WKUserScript {
    override init() {
        super.init(
            source: """
            var ai = {
                prompt: function(prompt) {
                    window.webkit.messageHandlers.aiHandler.postMessage({ function: 'prompt', payload: prompt });
                },
                createTextSession: function(systemPrompt) {
                    window.webkit.messageHandlers.aiHandler.postMessage({ function: 'createTextSession', payload: systemPrompt });
                }
            };

            window.ai = ai;
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false,
            in: .page
        )
    }
}
// swiftlint:enable line_length
