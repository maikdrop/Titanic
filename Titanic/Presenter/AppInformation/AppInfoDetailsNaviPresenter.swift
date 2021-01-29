/*
MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit

// source: www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct AppInfoDetailsNaviPresenter {

    typealias Category = AppInfoViewController.Category
    typealias FileNames = AppStrings.FileNames
    typealias Storyboard = AppStrings.Storyboard

    // MARK: - Public API
    /**
     Presents informations about the app.
     
     - Paramater viewController: The presenting view controller.
     - Parameter category: The category of the app information.
     */
    func present(in viewController: UIViewController, for category: Category) {

        var informationDetailsVC: UIViewController?

        // creating a view controller accordingly to the category
        switch category {
        case .about, .legal:
            informationDetailsVC = self.createDynamicInformationVC(from: category)
        case .concept:
            informationDetailsVC =
                UIStoryboard(name: Storyboard.concept, bundle: nil)
                .instantiateViewController(withIdentifier: Storyboard.conceptVcIdentifier) as? AppConceptViewController
        case .rules:
            informationDetailsVC =
                UIStoryboard(name: Storyboard.gameRules, bundle: nil)
                .instantiateViewController(identifier: Storyboard.gameRulesVcIdentifier) as? GameRulesViewController
        }

        // presenting navigation controller with picked view controller
        if let navigationController = viewController.navigationController, let infoVC = informationDetailsVC {
            infoVC.navigationItem.title = category.stringValue
            navigationController.pushViewController(infoVC, animated: true)
        }
    }
}

private extension AppInfoDetailsNaviPresenter {

    /**
     Creates a view controller that contains informations about the app.
     
     - Parameter category: The category of app information.
     
     - returns: The view controller that contains informations about the app.
     */
    private func createDynamicInformationVC(from category: Category) -> DynamicInformationTableViewController {
        let appInformationVC = DynamicInformationTableViewController()
        if category == .about {
            appInformationVC.dataSource = [readTextFromFile(fileName: FileNames.aboutFileName, with: FileNames.txtExt)]
        }
        if category == .legal {
            appInformationVC.dataSource =
                [readTextFromFile(fileName: FileNames.legalNotices, with: FileNames.txtExt)]
        }
        return appInformationVC
    }
}
