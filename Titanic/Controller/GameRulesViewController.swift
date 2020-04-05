//
//  GameRulesViewController.swift
//  Titanic
//
//  Created by Maik on 03.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameRulesViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var textFileContent = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFileContent = HelperFunctions.readTextFile(fileName: "Rules")
        makeAttributedString()
    }
    
    private func makeAttributedString() {
        let attributeSystemFont:  [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17)]
        let attributeBoldSystemFont: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18)]
        let atrributedString = NSMutableAttributedString()
        for string in textFileContent {
            if string.contains("Goal:") || string.contains("Usage:") {
                atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeBoldSystemFont))
            } else {
                 atrributedString.append(NSMutableAttributedString(string:string, attributes: attributeSystemFont))
            }
        }
        textView.attributedText = atrributedString
    }
}
