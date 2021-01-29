/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class AppConceptViewController: UIViewController {

    typealias FileNames = AppStrings.FileNames

    // MARK: - IBOutlets
    @IBOutlet private weak var designPatternInnerStackView: UIStackView! {
        didSet {
            let contentArray = [
                "1. " + AppStrings.Concept.designPatternTitle + "\n",
                readTextFromFile(fileName: FileNames.designPatternFileName, with: FileNames.txtExt)]
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
                "2. " + AppStrings.Concept.avoidMassiveVCTitle + "\n",
                readTextFromFile(fileName: FileNames.avoidMassiveVCFileName, with: FileNames.txtExt)]
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
                "\n" + "3. " + AppStrings.Concept.layoutTitle + "\n",
                readTextFromFile(fileName: FileNames.adaptingLayoutFileName, with: FileNames.txtExt),
                "",
                readTextFromFile(fileName: FileNames.animationFileName, with: FileNames.txtExt)]
            for index in 0..<layoutInnerStackView.arrangedSubviews.count {
                if let label = layoutInnerStackView.arrangedSubviews[index] as? UILabel {
                    label.text = contentArray[optional:index] ?? ""
                }
            }
        }
    }

    deinit {
        print("DEINIT AppConceptViewController")
    }
}

// MARK: - Default methods
extension AppConceptViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
    }
}
