//
//  HighscoreListPresenterTests.swift
//  TitanicTests
//
//  Created by Maik on 29.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class HighscoreListPresenterTests: XCTestCase {

    var sut: HighscoreListPresenter!

    override func setUp() {
        super.setUp()
        sut = HighscoreListPresenter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testPresentHighscoreList() {
        let title = "Top 10"
        let mockGameViewController = MockGameViewController()
        let highscoreListVC: HighscoreListTableViewController?

        sut.present(in: mockGameViewController)

        highscoreListVC = (mockGameViewController.presentViewControllerTarget as? UINavigationController)?
            .viewControllers.first as? HighscoreListTableViewController

        if let highscoreList = highscoreListVC {
            XCTAssertEqual(highscoreList.navigationItem.title, title)
        }
        XCTAssertNotNil(highscoreListVC)
    }
}
