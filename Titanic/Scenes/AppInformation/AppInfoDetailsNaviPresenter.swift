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
struct AppInfoDetailsNaviPresenter {

    typealias Category = AppInfoViewController.Category

    // MARK: - Public API
    /**
     Presents informations about the app.
     
     - Paramater viewController: presenting ViewController
     - Parameter cellText: text of cell from presenting ViewController
     */
    func present(in viewController: UIViewController, for category: Category) {

        var informationDetailsVC: UIViewController?

        // creating ViewController according to category
        switch category {
        case .about, .legal:
            informationDetailsVC = self.createDynamicInformationVC(from: category)
        case .concept:
            informationDetailsVC =
                UIStoryboard(name: conceptStoryboard, bundle: nil)
                .instantiateViewController( withIdentifier: conceptVcIdentifier) as? AppConceptViewController
        case .rules:
            informationDetailsVC =
                UIStoryboard(name: gameRulesStoryboard, bundle: nil)
                .instantiateViewController(identifier: gameRulesVcIdentifier) as? GameRulesViewController
        }

        // presenting navigationController with picked ViewController
        if let navigationController = viewController.navigationController, let infoVC = informationDetailsVC {
            infoVC.navigationItem.title = category.stringValue
            navigationController.pushViewController(infoVC, animated: true)
        }
    }
}

private extension AppInfoDetailsNaviPresenter {

    /**
     Creates a view controller that contains informations about the app.
     
     - Parameter cellText: text of cell from presenting view controller
     
     - returns: view controller that contains informations about the app
     */
    private func createDynamicInformationVC(from category: Category) -> DynamicInformationTableViewController {
        let appInformationVC = DynamicInformationTableViewController()
        if category == .about {
            appInformationVC.dataSource = [readTextFromFile(fileName: aboutTheAppFileName, with: txtExt)]
        }
        if category == .legal {
            appInformationVC.dataSource = [readTextFromFile(fileName: licenseFileName, with: txtExt)]
        }
        return appInformationVC
    }
}

// MARK: - Constants
private extension AppInfoDetailsNaviPresenter {
    private var conceptStoryboard: String {"Concept"}
    private var conceptVcIdentifier: String {"ConceptViewController"}
    private var txtExt: String {"txt"}
    private var aboutTheAppFileName: String {"AboutTheApp"}
    private var licenseFileName: String {"MIT_License"}
    private var gameRulesStoryboard: String {"GameRules"}
    private var gameRulesVcIdentifier: String {"GameRulesViewController"}
}
