//
//  PreparationCountdownViewController.swift
//  Titanic
//
//  Created by Maik on 26.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import Combine

class PreparationCountdownViewController: UIViewController {

    // MARK: - Properties
    private lazy var preparationView = GameStateView(frame: view.frame)
    private let countHandler: (Int) -> Void
    private var cancellablePreparationCountdownTimer: Cancellable?
    private var interval: Double

    private var preparationCountdown: Int {
        didSet {
            if preparationCountdown == 0 {
                preparationView.label.text = AppStrings.Game.goLblTxt
                removePreparationAnimation()
                cancellablePreparationCountdownTimer?.cancel()
            } else {
                preparationView.label.text = preparationCountdown.description
            }
            countHandler(preparationCountdown)
        }
    }

    // MARK: - Create a prepearation countdown
    init(preparationCountdown: Int, animationInterval: Double, completionHandler: @escaping (Int) -> Void) {
        self.preparationCountdown = preparationCountdown
        self.interval = abs(animationInterval)
        self.countHandler = completionHandler
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT PreparationCountdownViewController")
    }
}

// MARK: - Default methods
extension PreparationCountdownViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addPreparationAnimation()
        startPreparationTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancellablePreparationCountdownTimer?.cancel()
    }
}

// MARK: - UI logic for preparation view and count
private extension PreparationCountdownViewController {

    /**
     Animates adding of preparation view with preparation count.
    */
    private func addPreparationAnimation() {
        view.addSubview(preparationView)
        preparationView.label.text = preparationCountdown.description
        UIView.animate(withDuration: interval) {
            self.preparationView.alpha = 0.8
        }
    }

    /**
     Starts preparation timer and reduces preparation count according to chosen interval.
    */
    private func startPreparationTimer() {
        cancellablePreparationCountdownTimer = Timer.publish(
            every: interval,
            on: .main,
            in: .common)
            .autoconnect()
            .sink { _ in
                self.preparationCountdown -= 1
        }
    }

    /**
     Animates removing of preparation view.
     */
    private func removePreparationAnimation() {
        UIView.animate(
            withDuration: interval + 0.5,
            animations: { self.preparationView.alpha = 0.0},
            completion: {_ in
                self.remove()
        })
    }
}
