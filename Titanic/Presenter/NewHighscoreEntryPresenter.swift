//
//  NewHighscoreEntryPresenter.swift
//  Titanic
//
//  Created by Maik on 01.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

//source: https://www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct NewHighscoreEntryPresenter {

    let title: String
    let message: String
    let handler: (Outcome) -> Void
    private let acceptTitle = AppStrings.CommonAlertAction.done
    private let rejectTitle = AppStrings.CommonAlertAction.cancel

    func present(in viewController: UIViewController) {
        var textDidChangeObserver: NSObjectProtocol?

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let acceptAction = UIAlertAction(title: acceptTitle, style: .default) { _ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.handler(.accepted(userName))
                if let observer = textDidChangeObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
            }
        }

        let rejectAction = UIAlertAction(title: rejectTitle, style: .cancel) { _ in
            self.handler(.rejected)
            if let observer = textDidChangeObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = AppStrings.NewHighscoreEntryAlert.textFieldPlaceholder
            textDidChangeObserver = NotificationCenter.default.addObserver(
                forName: UITextField.textDidChangeNotification,
                object: textField,
                queue: .main) {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    alert.actions.first?.isEnabled = textIsNotEmpty
                }
        })
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        alert.actions.first?.isEnabled = false
        viewController.present(alert, animated: true)
    }

    enum Outcome {
        case accepted(String)
        case rejected
    }
}
