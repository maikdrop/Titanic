//
//  PauseViewController.swift
//  Titanic
//
//  Created by Maik on 12.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    
    let gameStatus = GamePresenter.GameStatus.resume
    
    override func viewDidLoad() {
         view.addSubview(PauseView(frame: view.frame))
    }
}
