/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

struct MockPlayerHandling: DataHandling {

    var fetchingError = false

    typealias DataTyp = [TitanicGame.Player]

    typealias Handler = (Result<DataTyp, Error>) -> Void

    func save(player: DataTyp, then completion: Handler) {
        if player.contains(where: {player in
            player.name == "maikdrop"}) {
                completion(.success(player))
        } else {
            completion(.failure(DataHandlingError.writingError(message: AppStrings.ErrorAlert.writingErrorMessage)))
        }
    }

    func fetch(then completion: Handler) {

        if fetchingError {
            completion(.failure(DataHandlingError.readingError(message: AppStrings.ErrorAlert.readingErrorMessage)))
        } else {
            let player = [TitanicGame.Player(name: "maikdrop", drivenMiles: 0)]
            completion(.success(player))
        }
    }
}

class MockPlayerHandlingTests: XCTestCase {

    var sut: MockPlayerHandling!

    override func setUp() {
        super.setUp()
        sut = MockPlayerHandling()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFetchingPlayer() {

        let playerToTest = TitanicGame.Player(name: "maikdrop", drivenMiles: 0)

        sut.fetch {result in
            if case .success(let player) = result {
                XCTAssertEqual(playerToTest.name, player.first?.name)
                XCTAssertEqual(playerToTest.drivenMiles, player.first?.drivenMiles)
            } else {
                 XCTAssertTrue(false)
            }
        }
    }

    func testFetchingPlayerError() {

        sut.fetchingError = true

        sut.fetch {result in
            if case .failure(let error) = result {
                if let dataHandlingError = error as? DataHandlingError {
                    XCTAssertEqual(dataHandlingError.getErrorMessage(), AppStrings.ErrorAlert.readingErrorMessage)
                } else {
                    XCTAssertTrue(false)
                }
            } else {
                 XCTAssertTrue(false)
            }
        }
    }

    func testSavingPlayer() {

        let playerToTest = [TitanicGame.Player(name: "maikdrop", drivenMiles: 0)]

        sut.save(player: playerToTest) {result in
            if case .success(let loadedPlayer) = result {
                XCTAssertEqual(playerToTest.first?.name, loadedPlayer.first?.name)
                XCTAssertEqual(playerToTest.first?.drivenMiles, loadedPlayer.first?.drivenMiles)
            } else {
                XCTAssertTrue(false)
            }
        }
    }

    func testSavingPlayerError() {

        let playerToTest = [TitanicGame.Player(name: "noName", drivenMiles: 0)]

        sut.save(player: playerToTest) {result in
            if case .failure(let error) = result {
                if let dataHandlingError = error as? DataHandlingError {
                    XCTAssertEqual(dataHandlingError.getErrorMessage(), AppStrings.ErrorAlert.writingErrorMessage)
                } else {
                    XCTAssertTrue(false)
                }
            } else {
                XCTAssertTrue(false)
            }
        }
    }
}
