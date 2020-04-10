//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var highscoreListBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let highscoreList = HelperFunctions.getHighscoreList() {
             highscoreListBtn.isEnabled = highscoreList.count > 0
        }
    }
}
