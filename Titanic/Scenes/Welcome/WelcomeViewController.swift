/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import CoreData
import SwiftUI
import Combine

class WelcomeViewController: UIViewController {

    // MARK: - Properties
    private let icebergImageView = UIImageView(image: UIImage(named: AppStrings.ImageNames.launch))
    private var gamePicker = GamePickerDelegate()
    private var cancellableObserver: Cancellable?
    private var isTransitionInProgress = true

    // Buttons
    private lazy var appInfoBtn = UIBarButtonItem(
        title: AppStrings.Welcome.appInfoBtnTitle,
        style: .plain,
        target: self,
        action: #selector(appInfoBtnTapped))

    private lazy var storedGamesBtn = UIBarButtonItem(
        image: UIImage(systemName: AppStrings.ImageNames.storedGames),
        style: .plain,
        target: self,
        action: #selector(storedGamesBtnTapped))

    private lazy var speedBtn = UIBarButtonItem(
        image: UIImage(systemName: AppStrings.ImageNames.speedometer),
        style: .plain,
        target: self,
        action: #selector(speedBtnTapped))

    // MARK: - IBOutlets
    @IBOutlet private weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = AppStrings.Welcome.title
        }
    }

    @IBOutlet private weak var toolbar: UIToolbar! {
        didSet {
            let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let buttonItems = [storedGamesBtn, space, speedBtn]
            toolbar.setItems(buttonItems, animated: false)
        }
    }

    @IBOutlet private weak var startBtn: UIButton! {
        didSet {
            startBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    // MARK: - IBActions
    @IBAction private func startActionBtn(_ sender: UIButton) {
        TitanicGameViewNaviPresenter().present(in: self)
    }

    deinit {
        print("DEINIT TitanicWelcomeViewController")
        cancellableObserver?.cancel()
    }
}

 // MARK: - Default Methods
extension WelcomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = appInfoBtn
        setupIcebergLayout()
        setupIcebergAnimation()
        cancellableObserver = gamePicker.didChange.sink {[weak self] gamePicker in
            self?.startGame(from: gamePicker.storedGameDate)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storedGamesBtn.isEnabled = !isTransitionInProgress ? storedGameIsAvailable() : false
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent.modalPresentationStyle != .popover {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// MARK: - Popover delegation methods
extension WelcomeViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

// MARK: - Private on tap button actions
private extension WelcomeViewController {

    /**
     The action of the info button, that shows the app informations.
     */
    @objc private func appInfoBtnTapped() {
        self.navigationController?.pushViewController(AppInfoViewController(), animated: true)
    }

    /**
     The action of the stored button, that shows the stored games.
     */
    @objc private func storedGamesBtnTapped() {

        GameChooserNaviPresenter().present(in: self, delegate: gamePicker, cancelHandler: {
            self.storedGamesBtn.isEnabled = self.storedGameIsAvailable()
            self.presentedViewController?.dismiss(animated: true)
        })
    }

    /**
     The action of the speed button, that shows the speed options.
     */
    @objc private func speedBtnTapped() {
        let chooseSpeedTVC = ChooseSpeedTableViewController()
        chooseSpeedTVC.modalPresentationStyle = .popover
        chooseSpeedTVC.popoverPresentationController?.permittedArrowDirections = .down
        chooseSpeedTVC.popoverPresentationController?.delegate = self
        chooseSpeedTVC.popoverPresentationController?.barButtonItem = speedBtn
        chooseSpeedTVC.preferredContentSize = CGSize(width: 200, height: 150)
        self.present(chooseSpeedTVC, animated: true)
    }
}

// MARK: - Private methods for iceberg constraints and animation
private extension WelcomeViewController {

    /**
     Presents the first use instructions.
     */
    private func showFirstUseInstructions() {
        if let hideNextTime = UserDefaults.standard.value(forKey: AppStrings.UserDefaultKeys.rules) as? Bool {
            if !hideNextTime {
                FirstUseInstructionsNaviPresenter().present(in: self, doneHandler: {
                    self.presentedViewController?.dismiss(animated: true)
                })
            }
        } else {
            FirstUseInstructionsNaviPresenter().present(in: self, doneHandler: {
                self.presentedViewController?.dismiss(animated: true)
            })
        }
    }

    /**
     Setup the layout of the iceberg at the middle of the view.
     */
    private func setupIcebergLayout() {
        view.addSubview(icebergImageView)
        icebergImageView.translatesAutoresizingMaskIntoConstraints = false
        icebergImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        icebergImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }

    /**
     Setup the animation of the iceberg in the middle of the view.
     */
    private func setupIcebergAnimation() {
        actionBtns(enabled: false)
        let ratio = view.frame.width / icebergImageView.frame.width
        UIView.transition(
            with: icebergImageView,
            duration: transitionAnimationDuration,
            options: [],
            animations: {
                self.icebergImageView.transform = CGAffineTransform.identity.scaledBy(x: ratio, y: ratio)
        }, completion: { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: self.propertyAnimationDuration,
                delay: 0,
                options: [],
                animations: {
                    self.icebergImageView.transform = CGAffineTransform.identity.scaledBy(
                        x: self.scaleFactor,
                        y: self.scaleFactor)
                    self.icebergImageView.alpha = 0
            }, completion: { _ in
                self.cleanUpAfterIcebergAnimation()
                self.showFirstUseInstructions()
            })
        })
    }

    /**
     Cleans up the UI after the iceberg animation has finished.
     */
    private func cleanUpAfterIcebergAnimation() {
        icebergImageView.removeFromSuperview()
        icebergImageView.alpha = 1
        icebergImageView.transform = .identity
        actionBtns(enabled: true)
        isTransitionInProgress = false
    }

    /**
     Enables or disbales all action buttons.
     
     - Parameter enabled: false or true
     
     - Important: Action buttons should be disabled while animation is running and enabled when completed
     */
    private func actionBtns(enabled: Bool) {
        appInfoBtn.isEnabled = enabled
        startBtn.isEnabled = enabled
        speedBtn.isEnabled = enabled
        storedGamesBtn.isEnabled = enabled == true ? storedGameIsAvailable() : enabled
    }
}

// MARK: - Private methods for game handling
private extension WelcomeViewController {

    /**
     Checks if the database is empty or not
     
     - Returns: true if the database is not empty, false if the database is empty
     */
    private func storedGameIsAvailable() -> Bool {

        var gameIsAvailable = false

        GameHandling().fetchFromDatabase { result in
            if case .success(let game) = result, game != nil {
                gameIsAvailable = true
            }
        }
        return gameIsAvailable
    }

    /**
     Starts a stored game from a date.
     
     - Parameter date: date of storing
     */
    private func startGame(from date: Date?) {
        self.presentedViewController?.dismiss(animated: true) {
            TitanicGameViewNaviPresenter(storingDate: date).present(in: self)
        }
    }
}

 // MARK: - Constants
private extension WelcomeViewController {
    private var transitionAnimationDuration: Double {0.6}
    private var propertyAnimationDuration: Double {0.75}
    private var scaleFactor: CGFloat {0.1}
}
