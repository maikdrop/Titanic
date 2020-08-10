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

    func testStartGame() {

        let welcomeLbl = sut.staticTexts["Welcome To Titanic!"]
        let startBtn = sut.buttons["Start"]
        let startLbl = sut.staticTexts["Start"]
        let knotsLbl = sut.staticTexts["Knots: 0"]
        let milesLbl = sut.staticTexts["Miles: 0.0"]
        let crashesLbl =  sut.staticTexts["Crashes: 0"]
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
