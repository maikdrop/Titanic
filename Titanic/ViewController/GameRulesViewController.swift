//
//  GameRulesViewController.swift
//  Titanic
//
//  Created by Maik on 03.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameRulesViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            makeAttributedString()
        }
    }
    private lazy var textFileContent = readTextFile(fileName: RULES_FILE_NAME)
    
    private func makeAttributedString() {
        let scaledBoldFont = UIFontMetrics.default.scaledFont(for: UIFont.boldSystemFont(ofSize: 18))  
        let scaledFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17))
        let attributeSystemFont:  [NSAttributedString.Key: Any] = [.font: scaledFont]
        let attributeBoldSystemFont: [NSAttributedString.Key: Any] = [.font: scaledBoldFont]
        let atrributedString = NSMutableAttributedString()
        for string in textFileContent {
            if string.contains(GOAL_SECTION_NAME) || string.contains(USAGE_SECTION_NAME) {
                atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeBoldSystemFont))
            } else {
                atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeSystemFont))
            }
        }
        textView.attributedText = atrributedString
        textView.textColor = UIColor.white
    }
    
    private func readTextFile(fileName: String) -> [String] {
        var fileContents = ""
        var lineArray = [String]()
        if let resourceUrl = Bundle.main.url(forResource: fileName, withExtension: TEXT_FILE_EXTENSION) {
            do {
                fileContents = try NSString(contentsOf: resourceUrl, encoding: String.Encoding.utf8.rawValue) as String
            } catch {
                print(error.localizedDescription)
            }
            lineArray = fileContents.components(separatedBy: "|")
        }
        return lineArray
    }
}
