//
//  Collection+ElementOperations.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension Collection where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return self.filter {seen.insert($0).inserted}
    }
    subscript(optional index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
