// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import SwiftUI
import Foundation

class WindowAIHelper: TabContentScript {
    // MARK: Private
    private enum HandlerName: String, CaseIterable {
        case aiHandler
    }

    private enum Function: String, CaseIterable {
        case createTextSession
        case prompt
    }

    private var llmAgent: WindowAILLMAgent?

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
              let functionRaw = body["function"] as? String,
              let function = Function(rawValue: functionRaw),
              let payload = body["payload"] as? String else { return }

        Task { @MainActor [weak self] in
            await self?.handleAPICall(
                function: function,
                payload: payload,
                webView: message.webView
            )
        }
    }

    // MARK: Handling api calls
    @MainActor
    private func handleAPICall(
        function: Function,
        payload: String,
        webView: WKWebView?
    ) async {
        switch function {
        case Function.createTextSession:

            let logOutput: String
            do {
                llmAgent = try await WindowAILLMAgent.make(
                    systemPrompt: payload
                ) { progress in
                    Task { @MainActor [weak self] in
                        self?.consoleLogProgress(progress, to: webView)
                    }
                }

                logOutput = "success"
            } catch {
                logOutput = "failure. error: \(error)"
            }
            consoleLog(logOutput, to: webView)

        case Function.prompt:

            consoleLog("thinking...", to: webView)
            let answer = await llmAgent?.process(prompt: payload) ?? "null"
            consoleLog(answer, to: webView)
        }
    }
}

// MARK: Console logging
private extension WindowAIHelper {
    func consoleLog(_ result: String, to webView: WKWebView?) {
        let escapedResult = result.replacingOccurrences(of: "\n", with: "\\n")
        let js = "console.log(\"\(escapedResult)\");"
        webView?.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("Error returning result: \(error)")
            }
        }
    }

    func consoleLogProgress(_ progress: Double, to webView: WKWebView?) {
        let prettyProgressInfo = "model downloaded up to: " +
            String(format: "%.2f%%", progress * 100)
        consoleLog(prettyProgressInfo, to: webView)
    }
}
