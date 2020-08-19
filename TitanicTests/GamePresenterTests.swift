/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class GamePresenterTests: XCTestCase {

    var sut: GameViewPresenter!
    let icebergs = [ImageView]()
    let ship = ImageView()

    override func setUp() {
        super.setUp()
        sut = GameViewPresenter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testChangeGameStatusToNew() {

        let new = AppStrings.GameStatus.new
        let newStatus = GameViewPresenter.GameStatus.running

        sut.changeGameStatus(to: new)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

    func testChangeGameStatusToPause() {

        let pause = AppStrings.GameStatus.pause
        let newStatus = GameViewPresenter.GameStatus.pause

        sut.changeGameStatus(to: pause)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

    func testChangeGameStatusToResume() {

        let resume = AppStrings.GameStatus.resume
        let newStatus = GameViewPresenter.GameStatus.running

        sut.changeGameStatus(to: resume)

        XCTAssertEqual(newStatus, sut.gameStatus)
    }

}
