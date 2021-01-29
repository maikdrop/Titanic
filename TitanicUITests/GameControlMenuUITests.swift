/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import XCTest
@testable import Titanic

// UI-Tests done on real device: iPhone SE 2
class GameControlMenuUITests: XCTestCase {

    var sut: XCUIApplication!

    override func setUp() {
        UserDefaults.standard.set(true, forKey: "rules")
        sut = XCUIApplication()
        sut.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGameStateMenu() {

        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn =
            sut.navigationBars["Titanic.TitanicGameView"].children(matching: .button).element(boundBy: 1)
        let newBtn = sut.collectionViews.buttons["New"]
        let pauseBtn = sut.collectionViews.buttons["Pause"]
        let cancelBtn = sut.collectionViews.buttons["Save & Quit"]

        startBtn.tap()
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: controlBtn, handler: nil)
        waitForExpectations(timeout: 3, handler: {_ in
            controlBtn.tap()
        })

        XCTAssertTrue(newBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(pauseBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 1))
    }

    func testChangeGameStateToNew() {

        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn =
            sut.navigationBars["Titanic.TitanicGameView"].children(matching: .button).element(boundBy: 1)
        let newBtn = sut.collectionViews.buttons["New"]
        let countdownLbl = sut.staticTexts["3"]

        startBtn.tap()

        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: controlBtn, handler: nil)
        waitForExpectations(timeout: 3, handler: {_ in
            controlBtn.tap()
        })
        newBtn.tap()

        XCTAssertTrue(countdownLbl.exists)
    }

    func testChangeGameStateToPause() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn =
            sut.navigationBars["Titanic.TitanicGameView"].children(matching: .button).element(boundBy: 1)
        let pauseBtn = sut.collectionViews.buttons["Pause"]
        let pauseLbl = sut.staticTexts["Pause"]

        startBtn.tap()
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: controlBtn, handler: nil)
        waitForExpectations(timeout: 3, handler: {_ in
            controlBtn.tap()
        })

        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.exists)
    }

    func testChangeGameStateToResume() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn =
            sut.navigationBars["Titanic.TitanicGameView"].children(matching: .button).element(boundBy: 1)
        let pauseBtn = sut.collectionViews.buttons["Pause"]
        let pauseLbl = sut.staticTexts["Pause"]
        let resumeBtn = sut.collectionViews.buttons["Resume"]

        startBtn.tap()

        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: controlBtn, handler: nil)
        waitForExpectations(timeout: 3, handler: {_ in
            controlBtn.tap()
        })

        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.exists)

        controlBtn.tap()
        resumeBtn.tap()

        XCTAssertFalse(pauseLbl.exists)
    }

    func testSaveGame() {
        let startBtn = sut.buttons["Start"].staticTexts["Start"]
        let controlBtn =
            sut.navigationBars["Titanic.TitanicGameView"].children(matching: .button).element(boundBy: 1)
        let saveBtn = sut.collectionViews.buttons["Save & Quit"]
        let okBtn = sut.alerts["The game was saved successfully."].scrollViews.otherElements.buttons["Ok"]

        startBtn.tap()

        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: controlBtn, handler: nil)
        waitForExpectations(timeout: 3, handler: {_ in
            controlBtn.tap()
        })

        saveBtn.tap()

        XCTAssertTrue(okBtn.exists)
    }
}
