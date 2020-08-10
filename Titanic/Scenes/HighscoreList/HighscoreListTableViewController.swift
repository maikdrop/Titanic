//
//  HighscoreListTableViewController.swift
//  Titanic
//
//  Created by Maik on 31.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

final class HighscoreListTableViewController: UITableViewController {

    // MARK: - Properties
    private var latestEntry: Int?
    private let player: [TitanicGame.Player] = {
        var playerList = [TitanicGame.Player]()
        FileHandler().loadPlayerFile(then: {(result) in
            if case .success(let player) = result {
                playerList = player
            }
        })
        return playerList
    }()
}

// MARK: - Default Methods
extension HighscoreListTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let play = player.max(by: {$0.date < $1.date}) {
            latestEntry = player.firstIndex(of: play)
        }
    }
}

// MARK: - Table view data source
extension HighscoreListTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
       1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      player.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: highscoreEntryCell, for: indexPath)

        let highscoreEntryText = "\(indexPath.row + 1)" + ". " +
            player[indexPath.row].name + ": " + "\(player[indexPath.row].drivenMiles)" + " miles"
        let attributedString = NSAttributedString(
            string: highscoreEntryText,
            attributes: [.font: UIFont().scalableFont(
                forTextStyle: .body,
                fontSize: 17)])

        cell.textLabel?.attributedText = attributedString

        if indexPath.row == latestEntry {
            let attributedString = NSAttributedString(
            string: highscoreEntryText,
            attributes: [.font: UIFont().scalableWeightFont(
                forTextStyle: .body,
                fontSize: 18,
                weight: .bold)])

        cell.textLabel?.attributedText = attributedString
        }
        return cell
    }
}

// MARK: - Constants
extension HighscoreListTableViewController {
    private var highscoreEntryCell: String {"highscoreEntryCell"}
}
