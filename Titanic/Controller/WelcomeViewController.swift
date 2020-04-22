//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private var highscoreList = HelperFunctions.getHighscoreList()
    @IBOutlet weak var highscoreListBtn: UIBarButtonItem!
    @IBOutlet weak var startBtn: UIButton! {
        didSet {
            startBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if highscoreList != nil {
             highscoreListBtn.isEnabled = highscoreList!.count > 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHighscoreList" {
            if let navc = segue.destination as? UINavigationController {
                if let vc = navc.viewControllers.first as? HighscoreListTableViewController {
                    vc.highscoreList = highscoreList!
                }
            }
        }
    }
}
