//
//  GameRulesViewController.swift
//  Titanic
//
//  Created by Maik on 03.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameRulesViewController: UIViewController {
    
    @IBOutlet weak var goalTitleLbl: UILabel! {
        didSet {
            goalTitleLbl.attributedText = NSAttributedString(string: GOAL_SECTION_NAME, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    
    @IBOutlet weak var usageTitleLbl: UILabel! {
        didSet {
            usageTitleLbl.attributedText = NSAttributedString(string: USAGE_SECTION_NAME, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue])
        }
    }
    @IBOutlet weak var usageContentLbl: UILabel! {
        didSet {
            usageContentLbl.text = rules.reduce("",+).replacingOccurrences(of: "|", with: "\n")
        }
    }
    
    private lazy var rules: [String] = {
        var content = readTextFromFile(fileName: RULES_FILE_NAME, with: TEXT_FILE_EXT)
        return content.components(separatedBy: "|")
    }()
}
