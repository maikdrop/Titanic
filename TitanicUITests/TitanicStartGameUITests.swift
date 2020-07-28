//
//  TitanicStartGameUITests.swift
//  TitanicUITests
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class TitanicStartGameUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    func testStartGame() {

        let welcomeLbl = app.staticTexts["Welcome To Titanic!"]
        let startBtn = app.buttons["Start"]
        let startLbl = app.staticTexts["Start"]
        let knotsLbl = app.staticTexts["Knots: 0"]
        let milesLbl = app.staticTexts["Miles: 0.00"]
        let crashesLbl =  app.staticTexts["Crashes: 0"]
        let countdownLbl = app.staticTexts["00"]

        XCTAssertTrue(welcomeLbl.exists)
        XCTAssertTrue(startLbl.exists)

        startBtn.tap()

        XCTAssertTrue(knotsLbl.exists)
        XCTAssertTrue(milesLbl.exists)
        XCTAssertTrue(crashesLbl.exists)
        XCTAssertTrue(countdownLbl.exists)
    }
}
