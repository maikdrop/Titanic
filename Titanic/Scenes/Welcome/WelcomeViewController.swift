//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

final class WelcomeViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet private weak var appInformationBtn: UIBarButtonItem! {
        didSet {
            appInformationBtn.title = AppStrings.Welcome.leftBarBtnTitle
            appInformationBtn.isEnabled = false
        }
    }
    @IBOutlet private weak var rulesBtn: UIBarButtonItem! {
        didSet {
            rulesBtn.title = AppStrings.Welcome.rightBarBtnTitle
            rulesBtn.isEnabled = false
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
            startBtn.isEnabled = false
        }
    }

    // MARK: - Button Action
    @IBAction private func appInformationBarActionBtn(_ sender: UIBarButtonItem) {
        if let navigator = navigationController {
            let destinationVC = AppInformationTableViewController()
            destinationVC.title = appInformationBtn.title
            navigator.pushViewController(destinationVC, animated: true)
        }
    }

    @IBAction private func rulesBarActionBtn(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let gameRulesVC = storyboard.instantiateViewController(
            withIdentifier: viewControllerIdentifier) as? GameRulesViewController {
            gameRulesVC.navigationItem.title = rulesBtn.title
            if let navigator = navigationController {
                navigator.pushViewController(gameRulesVC, animated: true)
            }
        }
    }
}

 // MARK: - Default Methods
extension WelcomeViewController {

    override func viewDidLayoutSubviews() {
        icebergAnimation()
    }
}

// MARK: - Private method for animation stuff
private extension WelcomeViewController {

    private func icebergAnimation() {
        let imageView = UIImageView(image: UIImage(named: launchImageFileName))
        imageView.center = startBtn.center
        view.addSubview(imageView)
        let ratio = view.frame.width / imageView.frame.width
        UIView.transition(
            with: imageView,
            duration: transitionAnimationDuration,
            options: [],
            animations: {
                imageView.transform = CGAffineTransform.identity.scaledBy(x: ratio, y: ratio)
        }, completion: { _ in
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: self.propertyAnimationDuration,
                delay: 0,
                options: [],
                animations: {
                    imageView.transform = CGAffineTransform.identity.scaledBy(
                        x: self.scaleFactor,
                        y: self.scaleFactor)
                    imageView.alpha = 0
            }, completion: { _ in
                imageView.isHidden = true
                imageView.alpha = 1
                imageView.transform = .identity
                self.appInformationBtn.isEnabled = true
                self.rulesBtn.isEnabled = true
                self.startBtn.isEnabled = true
            })
        })
    }
}

 // MARK: - Constants
extension WelcomeViewController {
    private var transitionAnimationDuration: Double {0.6}
    private var propertyAnimationDuration: Double {0.75}
    private var scaleFactor: CGFloat {0.1}
    private var storyboardName: String {"GameRules"}
    private var viewControllerIdentifier: String {"GameRulesViewController"}
    private var launchImageFileName: String {"LaunchImage"}
}
