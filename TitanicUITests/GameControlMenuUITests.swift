/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import XCTest
@testable import Titanic

class GameControlMenuUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testGameStatusMenu() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let controlBtn = app.navigationBars["Titanic.GameView"].buttons["Control"]
        let newBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let cancelBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Cancel"]

        startBtn.tap()
        controlBtn.tap()

        XCTAssertTrue(newBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(pauseBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 1))
    }

    func testChangeGameStatusToNew() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let controlBtn = app.navigationBars["Titanic.GameView"].buttons["Control"]
        let newBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let countdownLbl = app.staticTexts["3"]

        startBtn.tap()

        XCTAssertTrue(countdownLbl.waitForExistence(timeout: 0))

        controlBtn.tap()
        newBtn.tap()

        XCTAssertTrue(countdownLbl.waitForExistence(timeout: 0))
    }

    func testChangeGameStatusToPause() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let controlBtn = app.navigationBars["Titanic.GameView"].buttons["Control"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = app.staticTexts["Pause"]

        startBtn.tap()
        controlBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.waitForExistence(timeout: 0))
    }

    func testChangeGameStatusToResume() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let controlBtn = app.navigationBars["Titanic.GameView"].buttons["Control"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = app.staticTexts["Pause"]
        let resumeBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Resume"]

        startBtn.tap()
        controlBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.waitForExistence(timeout: 0))

        controlBtn.tap()
        resumeBtn.tap()

        XCTAssertFalse(pauseLbl.waitForExistence(timeout: 0))
    }
}
