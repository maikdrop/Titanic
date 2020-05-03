//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton! {
        didSet {
            startBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }
}
