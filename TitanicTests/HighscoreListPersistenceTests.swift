/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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

        sut.saveToFile(data: playersToSave) {result in
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

        sut.fetchFromFile {result in
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
