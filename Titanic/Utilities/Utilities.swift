//
//  Utilities.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

func readTextFromFile(fileName: String, with typeExtension: String) -> String {
    var fileContents = ""
    if let resourceUrl = Bundle.main.url(forResource: fileName, withExtension: typeExtension) {
        do {
            fileContents = try NSString(contentsOf: resourceUrl, encoding: String.Encoding.utf8.rawValue) as String
        } catch {
            print(error.localizedDescription)
        }
    }
    return fileContents
}
