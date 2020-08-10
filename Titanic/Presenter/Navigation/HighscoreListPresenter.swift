//
//  HighscoreListPresenter.swift
//  Titanic
//
//  Created by Maik on 02.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

//source: https://www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct HighscoreListPresenter {

    // MARK: - Public API
    func present(in viewController: UIViewController) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        if let list = storyboard.instantiateViewController(
            withIdentifier: viewControllerIdentifier) as? HighscoreListTableViewController {

            let navigationController = UINavigationController(rootViewController: list)

            list.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: navigationController,
                action: #selector(UIViewController.dismissWithAnimation)
            )
            list.navigationItem.title = "Top 10"
            viewController.present(navigationController, animated: true)
        }
    }
}

// MARK: - Constants
extension HighscoreListPresenter {
    private var storyboardName: String {"HighscoreList"}
    private var viewControllerIdentifier: String {"HighscoreListTableViewController"}
}

extension UIViewController {
    @objc func dismissWithAnimation() {
        self.dismiss(animated: true)
    }
}
