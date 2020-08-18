//
//  TitanicSnapshotTests.swift
//  TitanicSnapshotTests
//
//  Created by Maik on 17.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import XCTest
import SnapshotTesting
@testable import Titanic

//SnapshotTesting only works on simulator and 2 test runs needed (for creating and verifing image)
class HighscoreListTests: XCTestCase {

    func testHighscoreListTableView() {

        let storyboard = UIStoryboard(name: "HighscoreList", bundle: nil)
        if let highscoreList = storyboard.instantiateViewController(
            withIdentifier: "HighscoreListTableViewController") as? HighscoreListTableViewController {

            var players = [TitanicGame.Player]()

            for index in 0..<10 {
                let player = TitanicGame.Player(name: "maikdrop_" + String(index), drivenMiles: Double(index * 10))
                players.append(player)
            }
            // MARK: - set player public and change to var for testing purpose in HighscoreListTableViewController

            /* highscoreList.player = players */

            assertSnapshot(matching: highscoreList, as: .image)
        }
    }

}
