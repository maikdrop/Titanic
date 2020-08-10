/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
