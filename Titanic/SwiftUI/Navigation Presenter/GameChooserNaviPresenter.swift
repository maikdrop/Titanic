//
//  GameChooserNaviPresenter.swift
//  Titanic
//
//  Created by Maik on 02.12.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SwiftUI

struct GameChooserNaviPresenter {

    // MARK: - Properties
    private var persistentContainer = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    // MARK: - Public API
    /**
     Presents the view of the game.
     
     - Parameter viewController: presenting ViewController
     */
    func present(in viewController: UIViewController, delegate: GamePickerDelegate, cancelHandler: @escaping () -> Void) {

        if let context = persistentContainer?.viewContext {
            let gameChooserView = GameChooserView(gamePicker: delegate, cancelHandler: cancelHandler)
                .environment(\.managedObjectContext, context)
            let hostingVC = UIHostingController(rootView: gameChooserView)
            viewController.present(hostingVC, animated: true, completion: nil)
        }
    }
}
