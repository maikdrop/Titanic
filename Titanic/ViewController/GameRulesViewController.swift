//
//  GameRulesViewController.swift
//  Titanic
//
//  Created by Maik on 03.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameRulesViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
              makeAttributedString()
        }
    }
    private lazy var textFileContent = readTextFile(fileName: "Rules")
    
    private func makeAttributedString() {
        let scaledBoldFont = UIFontMetrics.default.scaledFont(for: UIFont.boldSystemFont(ofSize: 18))  
        let scaledFont = UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 17))
        let attributeSystemFont:  [NSAttributedString.Key: Any] = [.font: scaledFont]
        let attributeBoldSystemFont: [NSAttributedString.Key: Any] = [.font: scaledBoldFont]
        let atrributedString = NSMutableAttributedString()
        for string in textFileContent {
            if string.contains("Goal:") || string.contains("Usage:") {
                atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeBoldSystemFont))
            } else {
                 atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeSystemFont))
            }
        }
        textView.attributedText = atrributedString
        textView.textColor = UIColor.label
    }
}

extension GameRulesViewController {
    
    private func readTextFile (fileName: String) -> [String] {
        var fileContents = ""
        var lineArray = [String]()
        if let resourceUrl = Bundle.main.url(forResource: fileName, withExtension: FILE_EXTENSION) {
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
