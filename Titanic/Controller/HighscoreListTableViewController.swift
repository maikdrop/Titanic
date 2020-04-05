//
//  HighscoreListTableViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class HighscoreListTableViewController: UITableViewController {
    
    var highscoreList = [Player]()
    var boldIndex: Int?

    @IBAction func doneActionBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        cell.textLabel?.text = highscoreEntryText
        if indexPath.row == boldIndex {
            let attributeBoldSystemFont: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
            cell.textLabel?.attributedText = NSAttributedString(string: highscoreEntryText, attributes: attributeBoldSystemFont)
        }
        return cell
    }
}
