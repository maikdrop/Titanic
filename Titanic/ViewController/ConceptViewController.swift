//
//  ConceptViewController.swift
//  Titanic
//
//  Created by Maik on 30.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ConceptViewController: UIViewController {

      // MARK: - Properties
    @IBOutlet private weak var designPatternInnerStackView: UIStackView! {
        didSet {
            let contentArray = [
                AppStrings.Concept.designPatternTitle,
                "",
                readTextFromFile(fileName: designPatternFileName, with: txtExt)]
            for index in 0..<designPatternInnerStackView.arrangedSubviews.count {
                if let label = designPatternInnerStackView.arrangedSubviews[index] as? UILabel {
                    label.text = contentArray[optional:index] ?? ""
                }
            }
        }
    }

    @IBOutlet private weak var avoidingMassiveVCInnerStackView: UIStackView! {
        didSet {
            let contentArray = [
                AppStrings.Concept.avoidMassiveVCTitle,
                "",
                readTextFromFile(fileName: avoidMassiveVCFileName, with: txtExt)]
            for index in 0..<avoidingMassiveVCInnerStackView.arrangedSubviews.count {
                if let label = avoidingMassiveVCInnerStackView.arrangedSubviews[index] as? UILabel {
                    label.text = contentArray[optional:index] ?? ""
                }
            }
        }
    }

    @IBOutlet private weak var layoutInnerStackView: UIStackView! {
        didSet {
            let contentArray = [
                AppStrings.Concept.layoutTitle,
                "",
                readTextFromFile(fileName: layoutFileName, with: txtExt)]
            for index in 0..<layoutInnerStackView.arrangedSubviews.count {
                if let label = layoutInnerStackView.arrangedSubviews[index] as? UILabel {
                    label.text = contentArray[optional:index] ?? ""
                }
            }
        }
    }
}

// MARK: - Constants
extension ConceptViewController {
    private var designPatternFileName: String {"DesignPattern"}
    private var avoidMassiveVCFileName: String {"AvoidMassiveVC"}
    private var layoutFileName: String {"Layout"}
    private var txtExt: String {"txt"}
}
