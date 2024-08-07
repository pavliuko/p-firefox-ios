// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WebKit
import Foundation

enum HTMLContentOverviewProvider {
    private static let script = """
    function extractAndCombineText() {
        // Function to extract text from elements
        function extractTextFromElements(elements) {
            let textContent = '';
            elements.forEach(element => {
                textContent += element.textContent.trim() + ' ';
            });
            return textContent;
        }

        // Get text from common text-containing elements
        let paragraphTexts = extractTextFromElements(document.querySelectorAll('p'));
        let spanTexts = extractTextFromElements(document.querySelectorAll('span'));
        let divTexts = extractTextFromElements(document.querySelectorAll('div'));
        let headingTexts = extractTextFromElements(document.querySelectorAll('h1, h2, h3, h4, h5, h6'));

        // Combine all extracted texts
        let allText = paragraphTexts + spanTexts + divTexts + headingTexts;

        // Limit allText to 500 characters
        let limitedText = allText.slice(0, 500);

        // Get the current website address
        let websiteAddress = window.location.href;

        // Combine the website address and headers with the limited text
        let combinedText = `Website address: ${websiteAddress}\n\nContent:\n${limitedText}`;

        // Output the combined text
        return combinedText;
    }

    // Call the function and store the result
    extractAndCombineText();

    """

    static func invoke(
        on webView: WKWebView,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        webView.evaluateJavaScript(script) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let content = result as? String {
                completion(.success(content))
            } else {
                let extractionError = NSError(
                    domain: "HTMLContentSummaryError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to extract content."]
                )
                completion(.failure(extractionError))
            }
        }
    }
}
