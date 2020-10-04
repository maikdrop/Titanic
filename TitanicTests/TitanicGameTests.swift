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

    typealias Point = TitanicGame.Iceberg.Point
    typealias Size =  TitanicGame.Iceberg.Size

    var sut: TitanicGame!
    var icebergs = [TitanicGame.Iceberg]()
    let size = Size(width: 10, height: 10)

    override func setUp() {
        super.setUp()
        for index in 0..<10 {
            let point = Point(xCoordinate: Double(index), yCoordinate: Double(index) * size.height)
            let iceberg = TitanicGame.Iceberg(origin: point, size: size)
            icebergs += [iceberg]
        }
        sut = TitanicGame(icebergs: icebergs, dataHandler: PlayerHandling())
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
            XCTAssertEqual(sortedIcebergs[index].center.yCoordinate, icebergs[index].center.yCoordinate + factor)
        }
    }

    func testIcebergReachedEndOfView() {

        let height: Double = 10

        for index in 0..<sut.icebergs.count - 1 {
            sut.endOfViewReachedFromIceberg(at: index)
            if index == sut.icebergs.count - 1 {
                let last = Double(index) * height
                XCTAssertEqual(sut.icebergs[index].origin.yCoordinate, -(2 * last) - sut.icebergs[0].origin.yCoordinate)
            } else {
                XCTAssertEqual(sut.icebergs[index].origin.yCoordinate, -(Double((index + 1)) * height))
            }
        }
    }

    func testCollisionBetweenShipAndIceberg() {

        sut.collisionBetweenShipAndIceberg()

        let sortedIcebergs = sut.icebergs.sorted(by: <)

        XCTAssertEqual(sortedIcebergs, icebergs)
    }

    func testStartNewTitanicGame() {
        let miles = 0.0
        let crashCount = 0
        let knots = 50

        sut.startNewTitanicGame()

        XCTAssertEqual(sut.drivenSeaMiles, miles)
        XCTAssertEqual(sut.crashCount, crashCount)
        XCTAssertEqual(sut.knots, knots)
    }
}
