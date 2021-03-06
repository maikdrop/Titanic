/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class MockTitanicGameViewController: TitanicGameViewController {

    var presentViewControllerTarget: UIViewController?
    var mockGamePresenter: MockTitanicGameViewPresenter!

    override init(gameViewPresenter: TitanicGameViewPresenter) {
        super.init(gameViewPresenter: gameViewPresenter)
        mockGamePresenter = gameViewPresenter as? MockTitanicGameViewPresenter
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewControllerTarget = viewControllerToPresent
    }
}

class TitanicGameViewControllerTests: XCTestCase {

    var sut: MockTitanicGameViewController!

    override func setUp() {
        super.setUp()
        let mockGamePresenter = MockTitanicGameViewPresenter(storingDate: nil)
        sut = MockTitanicGameViewController(gameViewPresenter: mockGamePresenter)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGameViewController() {

        var count = 1

        sut.mockGamePresenter.moveIcebergsVertically()

        XCTAssertEqual(count, sut.mockGamePresenter.count)

        count = 2

        sut.mockGamePresenter.endOfViewReachedFromIceberg(at: 0)

        XCTAssertEqual(count, sut.mockGamePresenter.count)

        count = 3

        sut.mockGamePresenter.intersectionOfShipAndIceberg()

        XCTAssertEqual(count, sut.mockGamePresenter.count)

        count = 4

        sut.mockGamePresenter.nameForHighscoreEntry(userName: "", completion: {_ in})

        XCTAssertEqual(count, sut.mockGamePresenter.count)
    }
}
