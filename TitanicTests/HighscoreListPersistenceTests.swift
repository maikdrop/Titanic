//
//  HighscoreListPersistenceTests.swift
//  TitanicTests
//
//  Created by Maik on 05.10.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class HighscoreListPersistenceTests: XCTestCase {

    var sut: PlayerHandling!

    override func setUp() {
        super.setUp()
        sut = PlayerHandling(fileName: "highscore_test.json")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSaveFile() {

        let player = TitanicGame.Player(name: "maikdrop", drivenMiles: 0.0)
        let playersToSave = Array(repeating: player, count: 10)

        sut.save(player: playersToSave) {result in
            if case .success(let players) = result {
                XCTAssertEqual(playersToSave, players)
            } else {
                XCTAssertTrue(false)
            }
        }
    }

    func testfetchFile() {

        let player = TitanicGame.Player(name: "maikdrop", drivenMiles: 0.0)
        let playersToFetch = Array(repeating: player, count: 10)

        sut.fetch {result in
            if case .success(let players) = result {
                for index in 0..<players.count {
                    XCTAssertEqual(playersToFetch[index].name, players[index].name)
                    XCTAssertEqual(playersToFetch[index].drivenMiles, players[index].drivenMiles)
                }
            } else {
                XCTAssertTrue(false)
            }
        }
    }
}
