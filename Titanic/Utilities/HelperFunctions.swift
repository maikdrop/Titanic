//
//  HelperFunctions.swift
//  Titanic
//
//  Created by Maik on 13.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct HelperFunctions {
    
    static func readTextFile (fileName: String) -> [String] {
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
