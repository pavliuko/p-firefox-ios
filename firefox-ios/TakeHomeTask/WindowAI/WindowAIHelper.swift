// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import SwiftUI
import Foundation

struct WindowAIHelper: TabContentScript {
    // MARK: Private
    private enum HandlerName: String, CaseIterable {
        case aiHandler
    }

    private enum Function: String {
        case createTextSession
        case prompt
    }

    private let llmAgent = LLMAgentBox()

    // MARK: TabContentScript
    static func name() -> String {
        "WindowAIHelper"
    }

    func scriptMessageHandlerNames() -> [String]? {
        HandlerName.allCases.map { $0.rawValue }
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage
    ) {
        guard let body = message.body as? [String: Any],
              let function = body["function"] as? String else { return }

        switch function {
        case Function.createTextSession.rawValue:
            if let systemPrompt = body["systemPrompt"] as? String {
                Task {
                    let result: String
                    do {
                        try await llmAgent.makeLLMAgent(systemPrompt: systemPrompt) { progress in
                            DispatchQueue.main.async {
                                consoleLogProgress(progress, to: message.webView)
                            }
                        }
                        result = "success"
                    } catch {
                        result = "failure. error: \(error)"
                    }
                    DispatchQueue.main.async {
                        consoleLog(result, to: message.webView)
                    }
                }
            }

        case Function.prompt.rawValue:
            if let prompt = body["payload"] as? String {
                Task {
                    let answer = await llmAgent.process(prompt: prompt) ?? "null"
                    DispatchQueue.main.async {
                        consoleLog(answer, to: message.webView)
                    }
                }
            }

        default:
            break
        }
    }

    // MARK: Private
    private func consoleLog(_ result: String, to webView: WKWebView?) {
        DispatchQueue.main.async {
            let escapedResult = result.replacingOccurrences(of: "\n", with: "\\n")
            let js = "console.log(\"\(escapedResult)\");"
            webView?.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("Error returning result: \(error)")
                }
            }
        }
    }

    private func consoleLogProgress(_ progress: Double, to webView: WKWebView?) {
        let prettyProgressInfo = "LLM Agent is downloading: " +
            String(format: "%.2f%%", progress * 100)
        consoleLog(prettyProgressInfo, to: webView)
    }
}

class LLMAgentBox {
    var llmAgent: WindowAILLMAgent?

    @MainActor
    func makeLLMAgent(
        systemPrompt: String,
        updateCallback: @escaping (Double) -> Void
    ) async throws {
        llmAgent?.stop()
        llmAgent = try await WindowAILLMAgent(
            systemPrompt: systemPrompt,
            updateCallback: updateCallback
        )
    }

    @MainActor
    func process(prompt: String) async -> String? {
        guard let llmAgent else {
            return .none
        }

        await llmAgent.respond(to: prompt)

        return llmAgent.output
    }
}
