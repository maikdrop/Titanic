/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class MockTitanicGameViewPresenter: TitanicGameViewPresenter {

    var count = 0

    override func moveIcebergsVertically() {
        count += 1
    }

    override func endOfViewReachedFromIceberg(at index: Int) {
        count += 1
    }

    override func intersectionOfShipAndIceberg() {
        count += 1
    }

    override func nameForHighscoreEntry(userName: String, completion: ((Error?) -> Void)?) {
        count += 1
    }
}

class MockTitanicGameViewPresenterTest: XCTestCase {

    var sut: MockTitanicGameViewPresenter!

    override func setUp() {
        super.setUp()
        sut = MockTitanicGameViewPresenter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testMoveIcebergsVertically() {

        let count = 1

        sut.moveIcebergsVertically()

        XCTAssertEqual(count, sut.count)
    }

    func testEndOfViewReachedFromIceberg() {

        let count = 1

        sut.endOfViewReachedFromIceberg(at: 0)

        XCTAssertEqual(count, sut.count)
    }

    func testIntersectionOfShipAndIceberg() {

        let count = 1

        sut.intersectionOfShipAndIceberg()

        XCTAssertEqual(count, sut.count)
    }

    func testNameForHighscoreEntry() {

        let count = 1

        sut.nameForHighscoreEntry(userName: "", completion: {_ in})

        XCTAssertEqual(count, sut.count)
    }
}
