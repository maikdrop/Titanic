//
//  HighscoreListTableViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class HighscoreListTableViewController: UITableViewController {
    
    private var latestEntry: Int?
    var highscoreList = [Player]()
    var drivenMiles: Double? {
        didSet {
            latestEntry = highscoreList.lastIndex{$0.drivenMiles == drivenMiles}
        }
    }

    @IBAction func doneActionBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highscoreList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highscoreEntry", for: indexPath)
        let highscoreEntryText = "\(indexPath.row + 1)" + ". " + highscoreList[indexPath.row].name + ": " + "\(highscoreList[indexPath.row].drivenMiles)" + " miles"
        cell.textLabel?.attributedText = NSAttributedString(string: highscoreEntryText, attributes: [.font: UIFont.scalableFont(forTextStyle: .body, fontSize: 17)])
        if indexPath.row == latestEntry {
            cell.textLabel?.attributedText = NSAttributedString(string: highscoreEntryText, attributes: [.font: UIFont.scalableWeightFont(forTextStyle: .body, fontSize: 18, weight: .bold)])
        }
        return cell
    }
}
