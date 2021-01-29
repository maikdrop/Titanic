/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
import CoreData
@testable import Titanic

class TitanicGameViewPresenterTest: XCTestCase {

    var sut: TitanicGameViewPresenter!
    var date: Date?
    let size = 5
    let slider: Float = 5.0
    let timer = 10
    let icebergCount = 6

    override func setUp() {
        super.setUp()
        sut = TitanicGameViewPresenter(storingDate: nil)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testGameEndAfterCrash() {
        
        let icebergs = createIcebergImageViews()
        
        sut.gameViewDidLoad(icebergs: icebergs)
        
        sut.changeGameState(to: .running)
        
        XCTAssertTrue(sut.gameState == .running)
        
        for _ in 0..<6 {
            sut.intersectionOfShipAndIceberg()
        }
        XCTAssertTrue(sut.gameState == .end)
    }

    // run testSaveGame() before testFetchGame()
    func testSaveGame() {

        let icebergs = createIcebergImageViews()
        
        sut.gameViewDidLoad(icebergs: icebergs)

        sut.saveGame(sliderValue: slider, timerCount: timer, completion: { error in
            XCTAssertNil(error)
        })
    }
    
    func testFetchGame() {
        
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        
        let request = GameObject.fetchGamesRequest(predicate: nil)
        
        do {
            let matches = try context?.fetch(request)
            
            if let lastGame = matches?.first {
                
                let array = lastGame.icebergs?.allObjects as? [IcebergObject]

                for index in 0..<array!.count {
                    
                    let boolCenterX = array?.contains(where: { $0.centerX == Double(index) + Double(size)/2 })
                    XCTAssertTrue(boolCenterX!)
                    
                    let boolCenterY = array?.contains(where: { $0.centerY == Double(index) + Double(size)/2 })
                    XCTAssertTrue(boolCenterY!)
                }
                XCTAssertEqual(lastGame.config?.sliderValue, slider)
                XCTAssertEqual(Int(lastGame.config!.timerCount), timer)
            }
        } catch {
            XCTAssertTrue(false)
        }
    }
    
    private func createIcebergImageViews() -> [ImageView] {
        
        var icebergs = [ImageView]()

        for index in 0..<icebergCount {
            let icebergView = ImageView()
            icebergView.image = UIImage(named: AppStrings.ImageNames.iceberg)
            icebergView.frame = CGRect(x: index, y: index, width: size, height: size)
            icebergs.append(icebergView)
        }
        return icebergs
    }
}
