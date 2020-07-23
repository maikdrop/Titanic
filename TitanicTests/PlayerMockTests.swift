//
//  PlayerMockTests.swift
//  TitanicTests
//
//  Created by Maik on 20.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class MockFileHandler: FileHandler {
   
    override func savePlayerToFile(player: [Player], then handler: (Result<[Player], Error>) -> Void) {
        var drivenMiles = 0.0
        if player.first?.name == "maikdrop" {
            drivenMiles += player.first!.drivenMiles
        }
    }
    
    override func loadPlayerFile(then handler: FileHandler.Handler) {
        let player = [Player(name: "maikdrop", drivenMiles: 10.0)]
        handler(.success(player))
    }
}


class TitanicMockTests: XCTestCase {

    var sut: GameViewPresenter!
    var icebergInitXOrigin = [Double]()
    var icebergInitYOrigin = [Double]()
    var icebergSize = [(width: Double, height: Double)]()
    
    override func setUp() {
        super.setUp()
        sut = GameViewPresenter(icebergInitXOrigin: icebergInitXOrigin, icebergInitYOrigin: icebergInitYOrigin, icebergSize: icebergSize)
        sut.fil
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

   
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
