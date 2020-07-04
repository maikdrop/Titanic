//
//  ConceptViewController.swift
//  Titanic
//
//  Created by Maik on 30.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ConceptViewController: UIViewController {

    var cellIdentifierFromParentVC = ""
    private lazy var lblTxtsConcept: [String] = {
        var stringArray = [String]()
        stringArray.append("About The Concept")
        stringArray.append("Design Pattern")
        stringArray.append("Layout")
        stringArray.append("Layout")
        stringArray.append(readTextFromFile(fileName: "", with: "txt"))
        stringArray.append(readTextFromFile(fileName: "AboutTheApp", with: "txt"))
               
        
        
        
        return stringArray
    }()
    
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            for index in 0..<stackView.arrangedSubviews.count {
                if let label = stackView.arrangedSubviews[index] as? UILabel {
                    label.text = lblTxtsConcept[optional:index] ?? ""
                }
            }
        }
    }
}
