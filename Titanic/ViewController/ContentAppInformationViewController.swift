//
//  ContentAppInformationViewController.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ContentAppInformationViewController: UIViewController {

    var cellIdentifierFromParentVC = ""
    private lazy var lblTxtsAboutTheApp: [String] = {
        var stringArray = [String]()
        stringArray.append("Individual app project")
        stringArray.append(readTextFromFile(fileName: "AboutTheApp", with: "txt"))
        return stringArray
    }()
    private lazy var lblTxtsLegalNotices: [String] = {
        var stringArray = [String]()
        stringArray.append("Software License")
        stringArray.append(readTextFromFile(fileName: "MIT_License", with: "txt"))
               return stringArray
    }()
    
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            switch cellIdentifierFromParentVC {
                case "aboutCell":
                    for index in 0..<stackView.arrangedSubviews.count {
                        if let label = stackView.arrangedSubviews[index] as? UILabel {
                            label.text = lblTxtsAboutTheApp[optional:index] ?? ""
                        }
                    }
                case "legalCell":
                    for index in 0..<stackView.arrangedSubviews.count {
                        if let label = stackView.arrangedSubviews[index] as? UILabel {
                            label.text = lblTxtsLegalNotices[optional:index] ?? ""
                        }
                    }
                default:
                    break
            }
        }
    }
    
}
