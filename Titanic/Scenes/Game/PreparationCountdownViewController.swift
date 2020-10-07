/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
        setupPreparationView()
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
     Setup of the preparation view.
    */
    private func setupPreparationView() {
        view.addSubview(preparationView)
        preparationView.label.text = preparationCountdown.description
    }

    /**
     Starts the preparation timer and reduces the preparation count.
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
     Animates theremoving of the preparation view.
     */
    private func removePreparationAnimation() {
        UIView.animate(
            withDuration: interval + intervalOffset,
            animations: { self.preparationView.alpha = 0.0},
            completion: {_ in
                self.remove()
        })
    }
}

// MARK: - Constants
private extension PreparationCountdownViewController {
    private var intervalOffset: Double {0.5}
}
