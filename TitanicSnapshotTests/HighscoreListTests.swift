/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import XCTest
import SnapshotTesting
@testable import Titanic

//SnapshotTesting only works on simulator and 2 test runs needed (for creating and verifing image)
class HighscoreListTests: XCTestCase {

    var sut: HighscoreListTableViewController!

    override func setUp() {
        super.setUp()
        sut = HighscoreListTableViewController(
            dataHandler: PlayerHandling(fileName: AppStrings.Highscore.fileName))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testHighscoreListTableView() {

        var players = [TitanicGame.Player]()

        for index in 0..<10 {
            let player = TitanicGame.Player(name: "maikdrop_" + String(index), drivenMiles: Double(index * 10))
            players.append(player)
        }
        // MARK: - uncomment next line and remove private from player for testing purpose in HighscoreListTableViewController
        sut.player = players
        assertSnapshot(matching: sut, as: .image)
    }
}
