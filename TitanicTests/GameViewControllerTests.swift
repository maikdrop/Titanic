//
//  GameViewControllerTests.swift
//  TitanicTests
//
//  Created by Maik on 28.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import SnapshotTesting
import XCTest
@testable import Titanic

//SnapshotTesting only works on simulator
class GameViewControllerTests: XCTestCase {

    func testGameView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let gameVc = storyboard.instantiateViewController(
            withIdentifier: "GameViewController") as? GameViewController {

            assertSnapshot(matching: gameVc, as: .image)
        }
    }

}
