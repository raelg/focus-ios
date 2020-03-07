/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

// Note: this test is tested as part of the base test case, and thus is disabled here.

class ErrorPageTest: BaseTestCase {

    override func setUp() {
        super.setUp()
        dismissFirstRunUI()
    }

    override func tearDown() {
        app.terminate()
        super.tearDown()
    }

    func testErrorPage() {
        loadWebPage("http://localhost:6573/error?description=An%20SSL%20error%20has%20occurred%20and%20a%20secure%20connection%20to%20the%20server%20cannot%20be%20made.&url=https%3A%2F%2Fwww.example.com%2F&key=b5f2d047-6865-4dbb-9e5a-4e171cf22b7d")
        waitForWebPageLoad()
        waitforHittable(element: app.buttons["Try again"])
        waitforExistence(element: app.staticTexts["An SSL error has occurred and a secure connection to the server cannot be made."])
        let urlBarTextField = app.textFields["URLBar.urlText"]
        guard let text = urlBarTextField.value as? String else {
            XCTFail()
            return
        }

        XCTAssert(text == "www.example.com")
        app.buttons["Try again"].tap()
        waitforExistence(element: app.staticTexts["Example Domain"])
    }


    func testErrorPageHistory() {
        loadWebPage("http://localhost:6573/error?description=An%20SSL%20error%20has%20occurred%20and%20a%20secure%20connection%20to%20the%20server%20cannot%20be%20made.&url=https%3A%2F%2Fwww.example.com%2F&key=b5f2d047-6865-4dbb-9e5a-4e171cf22b7d")
        loadWebPage("https://www.google.com")

        waitforHittable(element: app.buttons["Back"])
        app.buttons["Back"].press(forDuration: 1)
        app.cells["An SSL error has occurred and a secure connection to the server cannot be made."].tap()
        waitforNoExistence(element: app.menuItems["Back"])

        waitForWebPageLoad()
        waitforHittable(element: app.buttons["Try again"])
        waitforExistence(element: app.staticTexts["An SSL error has occurred and a secure connection to the server cannot be made."])
        let urlBarTextField = app.textFields["URLBar.urlText"]
        guard let text = urlBarTextField.value as? String else {
            XCTFail()
            return
        }

        XCTAssert(text == "www.example.com")
    }

    func testWrongKeyDoesntShowDomainFromUrlParameter() {
        loadWebPage("http://localhost:6573/error?description=An%20SSL%20error%20has%20occurred%20and%20a%20secure%20connection%20to%20the%20server%20cannot%20be%20made.&url=https%3A%2F%2Fwww.example.com%2F&key=e5991006-26c1-4b0b-b30e-1fdb234bff0e")
        waitForWebPageLoad()
        let urlBarTextField = app.textFields["URLBar.urlText"]
        guard let text = urlBarTextField.value as? String else {
            XCTFail()
            return
        }

        XCTAssert(text == "localhost")
    }

}
