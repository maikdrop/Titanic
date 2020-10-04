/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import XCTest
@testable import Titanic

class MockWelcomeViewController: WelcomeViewController {

    var presentViewControllerTarget: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewControllerTarget = viewControllerToPresent
    }
}

class NavigationPresenterTests: XCTestCase {

    func testPresentHighscoreList() {

        let sut = HighscoreListPresenter()

        let title = "Top 10"
        let mockTitanicGameViewController = MockTitanicGameViewController(gameViewPresenter: TitanicGameViewPresenter())
        let highscoreListVC: HighscoreListTableViewController?

        sut.present(in: mockTitanicGameViewController)

        highscoreListVC = (mockTitanicGameViewController.presentViewControllerTarget as? UINavigationController)?
            .viewControllers.first as? HighscoreListTableViewController

        if let highscoreList = highscoreListVC {
            XCTAssertEqual(highscoreList.navigationItem.title, title)
        }
        XCTAssertNotNil(highscoreListVC)
    }

    func testPresentGameView() {

        let sut = GameViewNavigationPresenter()
        let gameVC: TitanicGameViewController?

        let mockWelcomeViewController = MockWelcomeViewController()

        sut.presentGameView(in: mockWelcomeViewController)

        gameVC = (mockWelcomeViewController.presentViewControllerTarget as? UINavigationController)?
            .viewControllers.first as? TitanicGameViewController

        if let gameView = gameVC?.view.subviews.first as? TitanicGameView {

            XCTAssertEqual(gameView.scoreStackView.knotsLbl.text, AppStrings.Game.knotsLblTxt + "0")
            XCTAssertEqual(gameView.scoreStackView.drivenSeaMilesLbl.text, AppStrings.Game.drivenSeaMilesLblTxt + "0.0")
            XCTAssertEqual(gameView.scoreStackView.crashCountLbl.text, AppStrings.Game.crashesLblTxt + "0")
        }
        XCTAssertNotNil(gameVC)
    }
}
