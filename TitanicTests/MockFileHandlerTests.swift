//
//  MockFileHandlerTests.swift
//  TitanicTests
//
//  Created by Maik on 20.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class MockFileHandler: FileHandler {

    var drivenMiles = 0
    override func savePlayerToFile(player: [Player], then handler: (Result<[Player], Error>) -> Void) {
        if player.contains(where: {player in
            player.name == "maikdrop_1"
            }) {
                drivenMiles += 1
            }
    }

    override func loadPlayerFile(then handler: FileHandler.Handler) {
        let player = [Player(name: "maikdrop", drivenMiles: 0)]
        handler(.success(player))
    }
}

class MockFileHandlerTests: XCTestCase {

    var sut: GameViewPresenter!
    var mockFileHandler: MockFileHandler!
    var icebergInitXOrigin = [Double]()
    var icebergInitYOrigin = [Double]()
    var icebergSize = [(width: Double, height: Double)]()

    override func setUp() {
        super.setUp()
        sut = GameViewPresenter(
            icebergInitXOrigin: icebergInitXOrigin,
            icebergInitYOrigin: icebergInitYOrigin,
            icebergSize: icebergSize)
        mockFileHandler = MockFileHandler()

        //uncomment following line for testing purposes and set fileHandler object public in GameViewPresenter
//         sut.fileHandler = mockFileHandler
    }

    func testLoadingPlayer() {

        let playerName = "maikdrop"

        let name = sut.player?.first?.name

        XCTAssertEqual(playerName, name)
    }

    func testSavingPlayer() {

        let playerName = "maikdrop_1"

        sut.nameForHighscoreEntry(userName: playerName, completion: {_ in})

        XCTAssertEqual(1, mockFileHandler.drivenMiles)
    }
}
