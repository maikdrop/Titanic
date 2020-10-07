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
struct HighscoreListPresenter {

    // MARK: - Public API
    /**
     Presents a highscore list.
     
     - Parameter viewController: presenting ViewController
     */
    func present(in viewController: UIViewController) {

        let playerHandler = PlayerHandling(fileName: AppStrings.Highscore.fileName)
        let highscoreListTVC = HighscoreListTableViewController(dataHandler: playerHandler)

        let navigationController = UINavigationController(rootViewController: highscoreListTVC)

        highscoreListTVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: navigationController,
            action: #selector(UIViewController.dismissWithAnimation)
        )

        highscoreListTVC.navigationItem.title = highscoreListTitle
        highscoreListTVC.navigationItem.largeTitleDisplayMode = .always

        viewController.present(navigationController, animated: true)
    }
}

// MARK: - Constants
extension HighscoreListPresenter {
    private var highscoreListTitle: String {"Top 10"}
    private var storyboardName: String {"HighscoreList"}
    private var viewControllerIdentifier: String {"HighscoreListTableViewController"}
}
