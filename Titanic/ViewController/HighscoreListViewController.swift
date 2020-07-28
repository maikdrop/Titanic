//
//  HighscoreListViewController.swift
//  Titanic
//
//  Created by Maik on 02.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class HighscoreListViewController: UIViewController {

    // MARK: - Properties
    private var tableView = UITableView()
    private var safeArea: UILayoutGuide!
    private var latestEntry: Int?
    private let player: [Player] = {
        var playerList = [Player]()
        FileHandler().loadPlayerFile(then: {(result) in
            if case .success(let player) = result {
                playerList = player
            }
        })
        return playerList
    }()
}

 // MARK: - Default Methods
extension HighscoreListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Top 10"
        safeArea = view.layoutMarginsGuide
        if let play = player.max(by: {$0.date < $1.date}) {
            latestEntry = player.firstIndex(of: play)
        }
        setupTableView()
        setupTableViewLayout()
    }
}

 // MARK: - Private methods for setting up table view
private extension HighscoreListViewController {

    private func setupTableView() {
        tableView.isUserInteractionEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: highscoreEntryCell)
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupTableViewLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}

 // MARK: - DataSource Methods
extension HighscoreListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        player.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
extension HighscoreListViewController {
    private var highscoreEntryCell: String {"highscoreEntryCell"}
}
