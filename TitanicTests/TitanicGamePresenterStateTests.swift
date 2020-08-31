/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class TitanicGamePresenterStateTests: XCTestCase {

    var sut: TitanicGamePresenter!
    let icebergs = [ImageView]()

    override func setUp() {
        super.setUp()
        sut = TitanicGamePresenter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testChangeGameStateToNew() {

        let new = AppStrings.GameState.new
        let newState = TitanicGamePresenter.GameState.running

        sut.changeGameState(to: new)

        XCTAssertEqual(newState, sut.gameState)
    }

    func testChangeGameStateToPause() {

        let pause = AppStrings.GameState.pause
        let newstate = TitanicGamePresenter.GameState.pause

        sut.changeGameState(to: pause)

        XCTAssertEqual(newstate, sut.gameState)
    }

    func testChangeGamestateToResume() {

        let resume = AppStrings.GameState.resume
        let newState = TitanicGamePresenter.GameState.running

        sut.changeGameState(to: resume)

        XCTAssertEqual(newState, sut.gameState)
    }

}
