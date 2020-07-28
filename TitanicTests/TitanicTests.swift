//
//  TitanicTests.swift
//  TitanicTests
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class TitanicTests: XCTestCase {

//    var sut: GamePresenter!
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
        sut.moveIcebergVertically(by: factor)

        let sortedIcebergs = sut.icebergs.sorted(by: <)

        for index in 0..<sut.icebergs.count {
            XCTAssertEqual(
            sortedIcebergs[index].center.yCoordinate, icebergInitYOrigin[index] + factor + icebergSize[index].height/2)
        }
    }

    func testResetIcebergVertically() {
        for index in 0..<sut.icebergs.count {
            sut.resetIcebergVertically(at: index)
            XCTAssertEqual(sut.icebergs[index].origin.yCoordinate, Double(0 - index))
        }
    }

    func testResetAllIcebergsAfterCollisionWithShip() {
        sut.resetAllIcebergsVerticallyAndHorizontally()
        let xOrigins = sut.icebergs.sorted(by: {$0.origin.xCoordinate < $1.origin.xCoordinate})
        let yOrigins = sut.icebergs.sorted(by: {$0.origin.yCoordinate < $1.origin.yCoordinate})

        for index in 0..<sut.icebergs.count {
            XCTAssertEqual(icebergInitXOrigin[index], xOrigins[index].origin.xCoordinate)
            XCTAssertEqual(icebergInitYOrigin[index], yOrigins[index].origin.yCoordinate)
        }
    }

}
