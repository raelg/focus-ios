/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

class ErrorPage {
    let error: String
    let url: String?

    init(error: String, url: String? = nil) {
        self.error = error
        self.url = url
    }

    var data: Data {
        let file = Bundle.main.path(forResource: "errorPage", ofType: "html")!

        let page = try! String(contentsOfFile: file)
            .replacingOccurrences(of: "%messageLong%", with: error)
            .replacingOccurrences(of: "%button%", with: UIConstants.strings.errorTryAgain)

        if let errorUrl = url {
            return page.replacingOccurrences(of: "%url%", with: errorUrl).data(using: .utf8)!
        }

        return page.data(using: .utf8)!
    }

}
