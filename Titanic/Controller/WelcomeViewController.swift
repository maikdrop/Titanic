//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    var highscoreList = [Player]()
    
    @IBOutlet weak var highscoreListBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let highscoreList = HelperFunctions.getHighscoreList() {
            self.highscoreList = highscoreList
        }
        highscoreListBtn.isEnabled = highscoreList.count > 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHighscoreList" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.topViewController as? HighscoreListTableViewController {
                    vc.highscoreList = self.highscoreList
                }
            }
        }
    }
}
