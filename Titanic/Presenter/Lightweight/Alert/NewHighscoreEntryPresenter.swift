/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit

//source: www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct NewHighscoreEntryPresenter {

    // MARK: - Properties
    let title: String
    let message: String
    let handler: (Outcome) -> Void
    private let acceptTitle = AppStrings.CommonAlertAction.done
    private let rejectTitle = AppStrings.CommonAlertAction.cancel

    // MARK: - Public API
    /**
     Presents an alert in order to get the users name.
     
     - Parameter viewController: presenting view controller
     */
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
}
