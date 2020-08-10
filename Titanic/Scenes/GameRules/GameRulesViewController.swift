//
//  GameRulesViewController.swift
//  Titanic
//
//  Created by Maik on 03.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

final class GameRulesViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var subheadlineLbl: UILabel! {
        didSet {
            subheadlineLbl.text = AppStrings.Rules.subheadlineTitle
        }
    }

    @IBOutlet weak var goalTitleLbl: UILabel! {
        didSet {
            goalTitleLbl.attributedText = NSAttributedString(string: AppStrings.Rules.goalSectionTitle, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }

    @IBOutlet weak var goalContentLbl: UILabel! {
        didSet {
            goalContentLbl.text = AppStrings.Rules.goalSectionContent
        }
    }

    @IBOutlet weak var usageTitleLbl: UILabel! {
        didSet {
            usageTitleLbl.attributedText = NSAttributedString(string: AppStrings.Rules.usageSectionTitle, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    @IBOutlet weak var usageContentLbl: UILabel! {
        didSet {
            usageContentLbl.text = AppStrings.Rules.usageSectionContent
            //.reduce("",+).replacingOccurrences(of: "|", with: "\n")
        }
    }
}
