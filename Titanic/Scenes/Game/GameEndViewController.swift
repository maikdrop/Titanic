//
//  EndViewController.swift
//  Titanic
//
//  Created by Maik on 26.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameEndViewController: UIViewController {

    private lazy var statusView = GameStateView(frame: view.frame)
    private let statusText: String
    private let interval: Double

    // MARK: - Create a game end view
    init(statusText: String, animationInterval: Double) {
        self.statusText = statusText
        self.interval = animationInterval
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT GameEndViewController")
    }
}

// MARK: - Default Methods
extension GameEndViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addStatusView()
    }
}

// MARK: - Private methods for UI Logic
private extension GameEndViewController {

    /**
     Animates the adding of the game state view with a status text.
     */
    private func addStatusView() {
        view.addSubview(statusView)
        statusView.label.text = statusText
        UIView.animate(withDuration: interval) {
            self.statusView.alpha = 0.8
        }
    }
}
