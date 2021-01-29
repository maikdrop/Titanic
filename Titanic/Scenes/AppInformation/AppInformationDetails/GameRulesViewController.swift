/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class GameRulesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var subheadlineLbl: UILabel! {
        didSet {
            subheadlineLbl.text = AppStrings.Rules.subheadlineTitle
        }
    }

    @IBOutlet private weak var goalTitleLbl: UILabel! {
        didSet {
            goalTitleLbl.attributedText = NSAttributedString(string: AppStrings.Rules.goalSectionTitle, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }

    @IBOutlet private weak var goalContentLbl: UILabel! {
        didSet {
            goalContentLbl.text = AppStrings.Rules.goalSectionContent
        }
    }

    @IBOutlet private weak var usageTitleLbl: UILabel! {
        didSet {
            usageTitleLbl.attributedText = NSAttributedString(string: AppStrings.Rules.usageSectionTitle, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }

    @IBOutlet private weak var firstRuleLbl: UILabel! {
        didSet {
            firstRuleLbl.text = AppStrings.Rules.firstRule
        }
    }
    @IBOutlet private weak var secondRuleLbl: UILabel! {
        didSet {
            secondRuleLbl.text = AppStrings.Rules.secondRule
        }
    }
    @IBOutlet private weak var thirdRuleLbl: UILabel! {
        didSet {
            thirdRuleLbl.text = AppStrings.Rules.thirdRule
        }
    }
    @IBOutlet private weak var fourthRuleLbl: UILabel! {
        didSet {
            fourthRuleLbl.text = AppStrings.Rules.fourthRule
        }
    }
    @IBOutlet private weak var fifthRuleLbl: UILabel! {
        didSet {
            fifthRuleLbl.text = AppStrings.Rules.fifthRule
        }
    }
}

// MARK: - Default methods
extension GameRulesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
    }
}
