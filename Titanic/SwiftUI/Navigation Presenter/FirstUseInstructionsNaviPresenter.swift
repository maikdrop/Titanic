//
//  FirstUseInstructionsPresenter.swift
//  Titanic
//
//  Created by Maik on 01.01.21.
//  Copyright © 2021 maikdrop. All rights reserved.
//

import UIKit
import SwiftUI

struct FirstUseInstructionsNaviPresenter {

    // MARK: - Public API
    /**
     Presents the instructions how to play the game.
     
     - Parameter viewController: presenting ViewController
     */
    func present(in viewController: UIViewController, doneHandler: @escaping () -> Void) {
        let rules = TitanicGameRules()
        let firstInstructionsView = HowToPlayView(titanicGameRules: rules, doneHandler: doneHandler)
        let hostingVC = UIHostingController(rootView: firstInstructionsView)
        viewController.present(hostingVC, animated: true, completion: nil)
    }
}
