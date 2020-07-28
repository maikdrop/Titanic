//
//  GameControlMenuUITests.swift
//  TitanicUITests
//
//  Created by Maik on 27.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class GameControlMenuUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    func testGameStatusMenu() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let shareBtn = app.navigationBars["Titanic.GameView"].buttons["Share"]
        let newBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let resetBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Reset"]
        let cancelBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Cancel"]

        startBtn.tap()
        shareBtn.tap()

        XCTAssertTrue(newBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(pauseBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(resetBtn.waitForExistence(timeout: 1))
        XCTAssertTrue(cancelBtn.waitForExistence(timeout: 1))
    }

    func testChangeGameStatusToNew() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let shareBtn = app.navigationBars["Titanic.GameView"].buttons["Share"]
        let newBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["New"]
        let countdownLbl = app.staticTexts["3"]

        startBtn.tap()

        XCTAssertTrue(countdownLbl.waitForExistence(timeout: 0))

        shareBtn.tap()
        newBtn.tap()

        XCTAssertTrue(countdownLbl.waitForExistence(timeout: 0))
    }

    func testChangeGameStatusToPause() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let shareBtn = app.navigationBars["Titanic.GameView"].buttons["Share"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = app.staticTexts["Pause"]

        startBtn.tap()
        shareBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.waitForExistence(timeout: 0))
    }

    func testChangeGameStatusToReset() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let shareBtn = app.navigationBars["Titanic.GameView"].buttons["Share"]
        let resetBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Reset"]
        let gameOverLbl = app.staticTexts["GAME OVER"]

        startBtn.tap()
        shareBtn.tap()
        resetBtn.tap()

        XCTAssertTrue(gameOverLbl.waitForExistence(timeout: 0))
    }

    func testChangeGameStatusToResume() {
        let startBtn = app.buttons["Start"].staticTexts["Start"]
        let shareBtn = app.navigationBars["Titanic.GameView"].buttons["Share"]
        let pauseBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Pause"]
        let pauseLbl = app.staticTexts["Pause"]
        let resumeBtn = app.sheets["Game Control"].scrollViews.otherElements.buttons["Resume"]

        startBtn.tap()
        shareBtn.tap()
        pauseBtn.tap()

        XCTAssertTrue(pauseLbl.waitForExistence(timeout: 0))

        shareBtn.tap()
        resumeBtn.tap()

        XCTAssertFalse(pauseLbl.waitForExistence(timeout: 0))
    }
}
