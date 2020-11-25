/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit

//source: www.swiftbysundell.com/basics/child-view-controllers
struct GameViewNavigationPresenter {

    private let storingDate: Date? = nil

    // MARK: - Public API
    /**
     Presents the view of the game.
     
     - Parameter viewController: presenting ViewController
     */
    func presentGameView(in viewController: UIViewController) {

        let presenter = TitanicGameViewPresenter(storingDate: storingDate)

        //View Presenter will be injected in View
        let gameVC = TitanicGameViewController(gameViewPresenter: presenter)

        if let navigationController = viewController.navigationController {
            navigationController.pushViewController(gameVC, animated: true)

        } else {
            let navigationController = UINavigationController(rootViewController: gameVC)
            viewController.present(navigationController, animated: true)
        }
    }
}
