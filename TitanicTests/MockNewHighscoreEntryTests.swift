//
//  MockNewHighscoreEntryTests.swift
//  TitanicTests
//
//  Created by Maik on 27.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
@testable import Titanic

class MockGameViewController: GameViewController {

    var presentViewControllerTarget: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewControllerTarget = viewControllerToPresent
    }
}

class NewHighscoreEntryTests: XCTestCase {

    var sut: NewHighscoreEntryPresenter!

    override func setUp() {
        super.setUp()
        sut = NewHighscoreEntryPresenter(title: "Title To Test", message: "Message To Test", handler: {_ in})
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testTitleAndMessage() {

        let expectedTitle = "Title To Test"
        let expectedMessage = "Message To Test"
        let expectedActionTitleFirst = "Done"
        let expectedActionTitleSecond = "Cancel"
        let expectedActionNumber = 2
        let mockGameViewController = MockGameViewController()
        var alertController: UIAlertController?

        sut.present(in: mockGameViewController)

        alertController = mockGameViewController.presentViewControllerTarget as? UIAlertController

        if let alert = alertController {

            let actualTitle = alert.title
            XCTAssertEqual(expectedTitle, actualTitle)

            let actualMessage = alert.message
            XCTAssertEqual(expectedMessage, actualMessage)

            let actualActionNumber = alert.actions.count
            XCTAssertEqual(expectedActionNumber, actualActionNumber)

            let actualActionTitleFirst = alert.actions[0].title
            XCTAssertEqual(expectedActionTitleFirst, actualActionTitleFirst)

            let actualActionTitleSecond = alert.actions[1].title
            XCTAssertEqual(expectedActionTitleSecond, actualActionTitleSecond)
        }

        XCTAssertNotNil(alertController)
    }
}
