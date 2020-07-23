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
        sut = GameViewPresenter(icebergInitXOrigin: icebergInitXOrigin, icebergInitYOrigin: icebergInitYOrigin, icebergSize: icebergSize)
    }
    
    func testChangeGameStatusToNew() {
        
        sut.changeGameStatus(to: .new)
        
        XCTAssertEqual(GameViewPresenter.GameStatus.new, sut.gameStatus)
    }
    
    func testChangeGameStatusToPause() {
        
        sut.changeGameStatus(to: .pause)
        
        XCTAssertEqual(GameViewPresenter.GameStatus.pause, sut.gameStatus)
    }
    
    func testChangeGameStatusToResume() {
        
        sut.changeGameStatus(to: .pause)
        sut.changeGameStatus(to: .resume)
        
        XCTAssertEqual(GameViewPresenter.GameStatus.resume, sut.gameStatus)
    }
    
    func testChangeGameStatusToReset() {
        
        sut.changeGameStatus(to: .reset)
        
        XCTAssertEqual(GameViewPresenter.GameStatus.reset, sut.gameStatus)
    }
    
    func testChangeGameStatusToEnd() {
        
        sut.changeGameStatus(to: .end)
        
        XCTAssertEqual(GameViewPresenter.GameStatus.end, sut.gameStatus)
    }
}
