/*
MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit

struct AppInformationContentPresenter {

    // MARK: - Public API
    /**
     Creates an App Information ViewController.
     
     - Paramater viewController: ViewController which presents an App Information ViewController
     - Parameter cellText: text of cell from presenting table view controller
     */
    func present(in viewController: UIViewController, for cellText: String) {
        var informationVC: UIViewController?

        if cellText == AppStrings.AppInformation.aboutTheAppLblTxt ||
            cellText == AppStrings.AppInformation.legalLblTxt {
            informationVC = AppInformationDetailTableViewController()
            if let infoVC = informationVC as? AppInformationDetailTableViewController {
                infoVC.cellIdentifierFromParentVC = cellText
                infoVC.navigationItem.title = cellText
            }
        } else if cellText == AppStrings.AppInformation.conceptLblTxt {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let conceptVC = storyboard.instantiateViewController(
                withIdentifier: viewControllerIdentifier) as? ConceptViewController {
                informationVC = conceptVC
                conceptVC.navigationItem.title = cellText
            }
        }

        if let navigationController = viewController.navigationController, let infoVC = informationVC {
           navigationController.pushViewController(infoVC, animated: true)
        }
    }
}
// MARK: - Constants
extension AppInformationContentPresenter {
    private var storyboardName: String {"Concept"}
    private var viewControllerIdentifier: String {"ConceptViewController"}
}
