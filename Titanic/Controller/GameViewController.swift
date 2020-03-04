//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    
    @IBOutlet weak var knotsLbl: UILabel!
    
    @IBOutlet weak var milesLbl: UILabel!
   
    @IBOutlet weak var crashCounterLbl: UILabel!
    
    @IBOutlet weak var timerLbl: UILabel!
    
 
    private var game: Titanic! {
        didSet{
            updateViewFromModel()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIcebergs()
//        game = Titanic(numberOfIcebergs: 10, at: <#T##[Point]#>, with: <#T##[Size]#>)
    }
    
    private func setupIcebergs() {
        
    }

    private func updateViewFromModel() {
        
    }

}

