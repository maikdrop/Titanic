//
//  MenuTableViewController.swift
//  Titanic
//
//  Created by Maik on 05.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

protocol MenuDelegate: class {
    func changeGameStatus(to newStatus: GameStatus)
}

import UIKit

class MenuTableViewController: UITableViewController {
    
    var gameStatus: GameStatus? = nil {
        didSet {
            menuItems = GameMenu(gameStatus: gameStatus!).menuItems
        }
    }
    
    private var menuItems = [String]()
    weak var delegate: MenuDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var contentSizeObserver : NSKeyValueObservation?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentSizeObserver = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            self?.preferredContentSize = CGSize(width: 120, height: tableView.contentSize.height)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentSizeObserver?.invalidate()
        contentSizeObserver = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_MENU_LIST, for: indexPath)
        
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
      // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true, completion: {
            guard let newGameStatus = GameMenu.getGameStatus(from: self.menuItems[indexPath.row]) else {
                print("unknownGameStatus - MenuTableViewController.didSelectRowAt: \(indexPath.row)")
                return
            }
            self.delegate?.changeGameStatus(to: newGameStatus)
        })
    }
}
