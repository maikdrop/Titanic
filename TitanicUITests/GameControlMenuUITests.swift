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
class GameControlMenuUITests: XCTestCase {

    var sut: XCUIApplication!

    override func setUp() {
        sut = XCUIApplication()
        sut.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGameStatusMenu() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn = sut.navigationBars["Titanic.GameView"].buttons["Control"]
        let newBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let pauseBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let cancelBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["Cancel"]

        startBtn.tap()
        controlBtn.tap()

        XCTAssertTrue(newBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(pauseBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 1))
    }

    func testChangeGameStatusToNew() {

        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn = sut.navigationBars["Titanic.GameView"].buttons["Control"]
        let newBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let countdownLbl = sut.staticTexts["3"]

        startBtn.tap()

        controlBtn.tap()
        newBtn.tap()

        XCTAssertTrue(countdownLbl.exists)
    }

    func testChangeGameStatusToPause() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn = sut.navigationBars["Titanic.GameView"].buttons["Control"]
        let pauseBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = sut.staticTexts["Pause"]

        startBtn.tap()
        controlBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.exists)
    }

    func testChangeGameStatusToResume() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn = sut.navigationBars["Titanic.GameView"].buttons["Control"]
        let pauseBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = sut.staticTexts["Pause"]
        let resumeBtn = sut.sheets["Game Control"].scrollViews.otherElements.buttons["Resume"]

        startBtn.tap()
        controlBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.exists)

        controlBtn.tap()
        resumeBtn.tap()

        XCTAssertFalse(pauseLbl.exists)
    }
}
