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
struct AppInformationDetailsPresenter {

    // MARK: - Public API
    /**
     Presents a ViewController that contains informations about the app.
     
     - Paramater viewController: presenting ViewController
     - Parameter cellText: text of cell from presenting ViewController
     */
    func present(in viewController: UIViewController, for cellText: String) {

        var informationDetailsVC: UIViewController?

        // picking ViewController according to cellText
        if cellText == AppStrings.AppInformation.aboutTheAppLblTxt ||
            cellText == AppStrings.AppInformation.legalLblTxt {

            informationDetailsVC = createAppInformationVC(from: cellText)

        } else if cellText == AppStrings.AppInformation.conceptLblTxt {

            informationDetailsVC = createConceptVC(from: cellText)
        }

        // presenting navigationController with picked ViewController
        if let navigationController = viewController.navigationController, let infoVC = informationDetailsVC {
           navigationController.pushViewController(infoVC, animated: true)
        }
    }
}

private extension AppInformationDetailsPresenter {

    /**
     Creates a ViewController that contains informations about the app.
     
     - Parameter cellText: text of cell from presenting ViewController
     
     - returns: ViewController that contains informations about the app
     */
    private func createAppInformationVC(from cellText: String) -> AppInformationTableViewController {

        let appInformationVC = AppInformationTableViewController()
        appInformationVC.cellIdentifierFromPresentigVC = cellText
        appInformationVC.navigationItem.title = cellText

        return appInformationVC
    }

    /**
     Creates a ViewController that contains the concept of the app.
     
     - Parameter cellText: text of cell from presenting ViewController
     
     - returns: ViewController that contains the concept of the app
     */
    private func createConceptVC(from cellText: String) -> AppConceptViewController? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        if let appConceptVC = storyboard.instantiateViewController(
            withIdentifier: viewControllerIdentifier) as? AppConceptViewController {
            appConceptVC.navigationItem.title = cellText
            return appConceptVC
        }
        return nil
    }
}

// MARK: - Constants
private extension AppInformationDetailsPresenter {
    private var storyboardName: String {"Concept"}
    private var viewControllerIdentifier: String {"ConceptViewController"}
}
