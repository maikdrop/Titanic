/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import XCTest
@testable import Titanic

class TitanicGameTests: XCTestCase {

    var sut: TitanicGame!
    var icebergInitXOrigin: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var icebergInitYOrigin: [Double] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var icebergSize = Array(repeating: (width: 20.0, height: 20.0), count: 10)

    override func setUp() {
        super.setUp()
        sut = TitanicGame(
                icebergInitXOrigin: icebergInitXOrigin,
                icebergInitYOrigin: icebergInitYOrigin,
                icebergSize: icebergSize)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testMoveIcebergVertically() {

        let factor = 10.0
        sut.moveIcebergsVertically()

        let sortedIcebergs = sut.icebergs.sorted(by: <)

        for index in 0..<sut.icebergs.count {
            XCTAssertEqual(
            sortedIcebergs[index].center.yCoordinate, icebergInitYOrigin[index] + factor + icebergSize[index].height/2)
        }
    }

    func testResetIceberg() {
        for index in 0..<sut.icebergs.count {
            sut.resetIceberg(at: index)
            XCTAssertEqual(sut.icebergs[index].origin.yCoordinate, Double(0 - index))
        }
    }

    func collisionBetweenShipAndIceberg() {

        sut.collisionBetweenShipAndIceberg()

        let xOrigins = sut.icebergs.sorted(by: {$0.origin.xCoordinate < $1.origin.xCoordinate})
        let yOrigins = sut.icebergs.sorted(by: {$0.origin.yCoordinate < $1.origin.yCoordinate})

        for index in 0..<sut.icebergs.count {
            XCTAssertEqual(icebergInitXOrigin[index], xOrigins[index].origin.xCoordinate)
            XCTAssertEqual(icebergInitYOrigin[index], yOrigins[index].origin.yCoordinate)
        }
    }

    func testCountdownUpdate() {

        let countdown = -1

        sut.countdownUpdate()

        XCTAssertEqual(-1, countdown)
    }

    func testStartNewRound() {
        let miles = 0.0
        let crashCount = 0
        let countdown = 30

        sut.startNewRound()

        XCTAssertEqual(sut.drivenSeaMiles, miles)
        XCTAssertEqual(sut.crashCount, crashCount)
        XCTAssertEqual(sut.countdownBeginningValue, countdown)
    }
}
