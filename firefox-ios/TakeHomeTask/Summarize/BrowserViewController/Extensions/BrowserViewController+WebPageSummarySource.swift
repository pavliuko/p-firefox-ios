// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension BrowserViewController {
    enum WebPageSummaryError: Error {
        case noWebView
        case contentOverviewProviderError(Error)
    }

    func getSourceForWebPageSummaryMaking(completion: @escaping (Result<String, Error>) -> Void) {
        guard let webView = tabManager.selectedTab?.currentWebView() else {
            completion(.failure(WebPageSummaryError.noWebView))
            return
        }

        HTMLContentOverviewProvider.invoke(on: webView) { result in
            completion(result.mapError(WebPageSummaryError.contentOverviewProviderError))
        }
    }
}
