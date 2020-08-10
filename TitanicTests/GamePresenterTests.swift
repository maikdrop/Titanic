//
//  GamePresenterTests.swift
//  TitanicTests
//
//  Created by Maik on 23.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class GamePresenterTests: XCTestCase {

    var sut: GameViewPresenter!
    var icebergInitXOrigin = [Double]()
    var icebergInitYOrigin = [Double]()
    var icebergSize = [(width: Double, height: Double)]()

    override func setUp() {
        super.setUp()
        sut = GameViewPresenter(
                icebergInitXOrigin: icebergInitXOrigin,
                icebergInitYOrigin: icebergInitYOrigin,
                icebergSize: icebergSize)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testChangeGameStatusToNew() {

        let new = AppStrings.GameStatus.new
        let newStatus = GameViewPresenter.GameStatus.running

        sut.changeGameStatus(to: new)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

    func testChangeGameStatusToPause() {

        let pause = AppStrings.GameStatus.pause
        let newStatus = GameViewPresenter.GameStatus.pause

        sut.changeGameStatus(to: pause)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

    func testChangeGameStatusToResume() {

        let resume = AppStrings.GameStatus.resume
        let newStatus = GameViewPresenter.GameStatus.running

        sut.changeGameStatus(to: resume)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

}
