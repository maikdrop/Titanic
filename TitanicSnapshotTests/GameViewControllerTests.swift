//
//  GameViewControllerTests.swift
//  TitanicSnapshotTests
//
//  Created by Maik on 17.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Titanic

//SnapshotTesting only works on simulator and 2 test runs needed (for creating and verifing image)
class GameViewControllerTests: XCTestCase {

    func testGameView() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        if let welcome = storyboard.instantiateViewController(
            withIdentifier: "WelcomeViewController") as? WelcomeViewController {
            GameViewPresenter().presentGameView(in: welcome)
            if let gameVc = welcome.presentedViewController {
                 assertSnapshot(matching: gameVc, as: .image)
            }
        }
    }

}
