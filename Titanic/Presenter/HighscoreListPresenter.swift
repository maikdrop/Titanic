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

    func present(in viewController: UIViewController) {
        let list = HighscoreListViewController()
        let navigationController = UINavigationController(rootViewController: list)

        list.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: navigationController,
            action: #selector(UIViewController.dismissWithAnimation)
        )
        viewController.present(navigationController, animated: true)
    }
}

extension UIViewController {
    @objc func dismissWithAnimation() {
        self.dismiss(animated: true)
    }
}
