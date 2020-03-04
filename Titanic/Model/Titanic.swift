//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Titanic {
    
    private(set) var icebergs = [Iceberg]()
    private var indexOfIcebergCollison: Int? {
        get{
            let collisions = icebergs.indices.filter {icebergs[$0].collosionWithShip}
            return collisions.count == 1 ? collisions.first : nil
        }
        set {
            for index in icebergs.indices {
                icebergs[index].collosionWithShip = (index == newValue)
            }
        }
    }
    
    init(numberOfIcebergs: Int, at point: [Point], with size: [Size]) {
        for index in 0..<numberOfIcebergs {
            self.icebergs.append(Iceberg(origin: point[index], size: size[index]))
        }
    }
    
    mutating func moveIceberg(at index: Int, to point: Point) {
        self.icebergs[index].center = point
    }
}
