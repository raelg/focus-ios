/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import GCDWebServers

private let LocalResources = ["rights-focus", "rights-klar", "licenses", "gpl"]

class LocalWebServer {
    static let sharedInstance = LocalWebServer(port: 6573)

    private let server = GCDWebServer()
    private let port: UInt
    private let base: String

    init(port: UInt) {
        self.port = port
        base = "http://localhost:\(port)"
        if LocalWebServer.storedSecret == nil {
            // Generate a random sk on first load
            UserDefaults.standard.set(UUID().uuidString, forKey: "sk")
        }
    }

    func start() {
        LocalResources.forEach { resource in
            let path = Bundle.main.path(forResource: resource, ofType: "html")!
            server.addGETHandler(forPath: "/\(resource).html", filePath: path, isAttachment: false, cacheAge: UInt.max, allowRangeRequests: true)
        }

        let stylesPath = Bundle.main.path(forResource: "style", ofType: "css")!
        server.addGETHandler(forPath: "/style.css", filePath: stylesPath, isAttachment: false, cacheAge: UInt.max, allowRangeRequests: true)

        server.addHandler(forMethod: "GET", path: "/error", request: GCDWebServerRequest.self) { (request: GCDWebServerRequest) in
            guard let params = request.query,
                  let key = params["key"],
                  let sk = LocalWebServer.storedSecret,
                  key == sk,
                  let error = params["description"],
                  let url = params["url"],
                  URL(string: url) != nil else {
                return GCDWebServerDataResponse(text: "")
            }
            let errorPage = ErrorPage(error: error, url: url)
            return GCDWebServerDataResponse(data: errorPage.data, contentType: "text/html; charset=UTF-8")
        }

        server.start(withPort: port, bonjourName: nil)
    }

    func URLForPath(_ path: String) -> URL! {
        return URL(string: "\(base)\(path)")
    }

    static var storedSecret: String? {
        get {
            return UserDefaults.standard.value(forKey: "sk") as? String
        }
    }

}
