/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
