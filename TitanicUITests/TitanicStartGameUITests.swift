/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

//UI-Tests done on simulator
class TitanicStartGameUITests: XCTestCase {

    var sut: XCUIApplication!

    override func setUp() {
        sut = XCUIApplication()
        sut.launchEnvironment = ["UITEST_DISABLE_ANIMATIONS": "YES"]
        sut.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testStartGame() {

        let welcomeLbl = sut.staticTexts["Welcome To Titanic!"]
        let startBtn = sut.buttons["Start"]
        let startLbl = sut.staticTexts["Start"]
        let knotsLbl = sut.staticTexts["Knots: 0"]
        let milesLbl = sut.staticTexts["Miles: 0.0"]
        let crashesLbl =  sut.staticTexts["Crashs: 0"]
        let countdownLbl = sut.staticTexts["00"]

        XCTAssertTrue(welcomeLbl.exists)
        XCTAssertTrue(startLbl.exists)

        startBtn.tap()

        XCTAssertTrue(knotsLbl.exists)
        XCTAssertTrue(milesLbl.exists)
        XCTAssertTrue(crashesLbl.exists)
        XCTAssertTrue(countdownLbl.exists)
    }
}
