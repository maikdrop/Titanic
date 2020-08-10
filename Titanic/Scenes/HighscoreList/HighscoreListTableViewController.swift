/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
