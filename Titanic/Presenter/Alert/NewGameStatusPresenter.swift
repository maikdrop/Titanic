//
//  NewGameStatusPresenter.swift
//  Titanic
//
//  Created by Maik on 01.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

//source: https://www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct NewGameStatusPresenter {

    // MARK: - Properties
    let status: GameViewPresenter.GameStatus
    let handler: (Outcome) -> Void

    // MARK: - Public API
    func present(in viewController: UIViewController) {
        let alert = UIAlertController(
            title: AppStrings.GameControlActionSheet.title,
            message: "",
            preferredStyle: .actionSheet)

        status.list.forEach({status in
            let defaultStyle = UIAlertAction.Style.default

            alert.addAction(UIAlertAction(title: status.stringValue, style: defaultStyle) {_ in
                self.handler(.accepted(status.stringValue))
            })
        })
        alert.addAction(UIAlertAction(title: AppStrings.CommonAlertAction.cancel, style: .cancel))
        viewController.present(alert, animated: true)
    }
}
