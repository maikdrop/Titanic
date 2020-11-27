/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Properties
    private lazy var icebergImageView = UIImageView(image: UIImage(named: launchImageFileName))

    @IBOutlet private weak var appInformationBtn: UIBarButtonItem! {
        didSet {
            appInformationBtn.title = AppStrings.Welcome.leftBarBtnTitle
        }
    }

    @IBOutlet private weak var storedGamesBtn: UIBarButtonItem! {
        didSet {
            storedGamesBtn.title = AppStrings.Welcome.rightBarBtnTitle
        }
    }

    @IBOutlet private weak var welcomeLabel: UILabel! {
        didSet {
            welcomeLabel.text = AppStrings.Welcome.headlineTitle
        }
    }
    @IBOutlet private weak var startBtn: UIButton! {
        didSet {
            startBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        }
    }

    // MARK: - Button Action
    @IBAction private func appInformationBarActionBtn(_ sender: UIBarButtonItem) {
        if let navigator = navigationController {
            let destinationVC = ChooseAppInformationTableViewController()
            destinationVC.title = appInformationBtn.title
            navigator.pushViewController(destinationVC, animated: true)
        }
    }

    @IBAction private func startActionBtn(_ sender: UIButton) {
        TitanicGameViewNaviPresenter().present(in: self)
    }
    @IBAction private func storedGamesActionBtn(_ sender: UIBarButtonItem) {
    }
}

 // MARK: - Default Methods
extension WelcomeViewController {

    override func viewDidLoad() {
        setupIcebergLayout()
        setupIcebergAnimation()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            setupIcebergLayout()
            setupIcebergAnimation()
        }
    }
}

// MARK: - Private methods for iceberg constraints and animation
private extension WelcomeViewController {

    /**
     Setup the layout of the iceberg in the middle of the view.
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
    }

    /**
     Enables or disbales all action buttons.
     
     - Parameter enabled: false or true
     
     - Important: Action buttons should be disabled while animation is running and enabled when completed
     */
    private func actionBtns(enabled: Bool) {
        appInformationBtn.isEnabled = enabled
        storedGamesBtn.isEnabled = enabled
        startBtn.isEnabled = enabled
    }
}

 // MARK: - Constants
private extension WelcomeViewController {
    private var transitionAnimationDuration: Double {0.6}
    private var propertyAnimationDuration: Double {0.75}
    private var scaleFactor: CGFloat {0.1}
    private var launchImageFileName: String {"LaunchImage"}
}
