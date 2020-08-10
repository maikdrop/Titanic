//
//  MockFileHandlerTests.swift
//  TitanicTests
//
//  Created by Maik on 20.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

struct MockFileHandler {

    func savePlayerToFile(player: [TitanicGame.Player], then handler: FileHandler.Handler) {
        if player.contains(where: {player in
            player.name == "maikdrop"}) {
                handler(.success(player))
        }
    }

    func loadPlayerFile(then handler: FileHandler.Handler) {
        let player = [TitanicGame.Player(name: "maikdrop", drivenMiles: 0)]
        handler(.success(player))
    }
}

class MockFileHandlerTests: XCTestCase {

    var sut: MockFileHandler!

    override func setUp() {
        super.setUp()
        sut = MockFileHandler()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testLoadingPlayer() {

        let playerToTest = TitanicGame.Player(name: "maikdrop", drivenMiles: 0)

        sut.loadPlayerFile(then: {result in
            if case .success(let player) = result {
                XCTAssertEqual(playerToTest.name, player.first?.name)
                XCTAssertEqual(playerToTest.drivenMiles, player.first?.drivenMiles)
            } else {
                 XCTAssertTrue(false)
            }
        })
    }

    func testSavingPlayer() {

         let playerToTest = [TitanicGame.Player(name: "maikdrop", drivenMiles: 0)]

        sut.savePlayerToFile(player: playerToTest, then: {result in
            if case .success(let loadedPlayer) = result {
                XCTAssertEqual(playerToTest.first?.name, loadedPlayer.first?.name)
                XCTAssertEqual(playerToTest.first?.drivenMiles, loadedPlayer.first?.drivenMiles)
            } else {
                XCTAssertTrue(false)
            }
        })
    }
}
