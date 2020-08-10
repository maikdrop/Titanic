//
//  AppInformationPresenter.swift
//  Titanic
//
//  Created by Maik on 10.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

struct AppInformationContentPresenter {

    // MARK: - Public API
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
