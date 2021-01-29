/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class GameHandlingTests: XCTestCase {

    typealias Iceberg = TitanicGame.Iceberg
    typealias Score = TitanicGame.Score
    typealias Config = TitanicGameViewPresenter.GameConfig
    
    var sut: GameHandling!
    let icebergCount = 6
    let size = 5.0

    override func setUp() {
        super.setUp()
        sut = GameHandling()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFetchFromDB() {
        
        //add 10 games to database
        updateDataBase()
        
        sut.fetchFromDatabase(then: { result in
            
            if case .success(let game) = result {
                XCTAssertNotNil(game)
            } else {
                XCTAssertTrue(false)
            }
        })
        
        if let games = fetchAllFromDB() {
            sut.delete(games: games, then: {_ in } )
        } else {
            XCTAssertTrue(false)
        }
        
        sut.fetchFromDatabase(then: { result in
            
            if case .success(let game) = result {
                XCTAssertNil(game)
            } else {
                XCTAssertTrue(false)
            }
        })
    }
    
    func testFetchAllFromDB() {
        
        //add 10 games to database
        updateDataBase()
        
        if let games = fetchAllFromDB() {
            XCTAssertFalse(games.isEmpty)
        } else {
            XCTAssertTrue(false)
        }
    }
    
    func testDeleteAllFromDB() {
        
        //add 10 games to database
        updateDataBase()
        
        if let games = fetchAllFromDB() {
            
            if !games.isEmpty {
                sut.delete(games: games, then: {_ in } )
                if let games = fetchAllFromDB() {
                    XCTAssertTrue(games.isEmpty)
                } else {
                    XCTAssertTrue(false)
                }
            } else {
                XCTAssertTrue(false)
            }
        } else {
            XCTAssertTrue(false)
        }
    }
    
    func testFetchSingleGame() {
        
        var storedDate: Date?
        
        //add 10 games to database
        updateDataBase()
        
        if let games = fetchAllFromDB() {
            
            if let latestGame = games.first {
                
                storedDate = latestGame.stored
            
            } else {
                XCTAssertTrue(false)
            }
        } else {
            XCTAssertTrue(false)
        }
        
        sut.fetchFromDatabase(matching: storedDate ?? Date(), then: { game in
            
            if case .success(let game) = game {
                
                XCTAssertEqual(storedDate, game?.stored)
                
            } else {
                XCTAssertTrue(false)
            }
        })
    }
    
    func testDeleteSingleGame() {
        
        var storedDate: Date?
        
        updateDataBase()
        
        if let games = fetchAllFromDB() {
            
            if let latestGame = games.first {
                
                storedDate = latestGame.stored
            
            } else {
                XCTAssertTrue(false)
            }
        } else {
            XCTAssertTrue(false)
        }
        
        sut.deleteGame(matching: storedDate ?? Date(), then: { result in
            
            if case .success(let game) = result {
                XCTAssertNotNil(game)
            } else {
                XCTAssertTrue(false)
            }
        })
        
        sut.fetchFromDatabase(matching: storedDate ?? Date(), then: { result in
            
            if case .success(let game) = result {
                XCTAssertNil(game)
            } else {
                XCTAssertTrue(false)
            }
        })
    }
    
    // MARK: - utility functions for DB handling
    private func updateDataBase() {
        
        var icebergs = [Iceberg]()
        
        for index in 0..<icebergCount {
            let point = Iceberg.Point(xCoordinate: Double(index), yCoordinate: Double(index))
            let size = Iceberg.Size(width: self.size, height: self.size)
            let iceberg = Iceberg(origin: point, size: size)
            icebergs.append(iceberg)
        }
        let score = Score(beginningKnots: 120)
        let config = Config(timerCount: 10, speedFactor: 10, sliderValue: 10)
        for _ in 0..<10 {
            sut.updateDatabase(icebergs: icebergs, score: score, gameConfig: config, then: { _ in })
        }
    }
    
    private func fetchAllFromDB() -> [GameObject]? {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        let request = GameObject.fetchGamesRequest(predicate: nil)
        
        return try? context?.fetch(request)
    }
}
