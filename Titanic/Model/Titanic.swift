//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Titanic {
    
    private(set) var icebergs: [Iceberg]
    private var indexOfIcebergCollisonWithShip: Int? {
        get{
            let collisions = icebergs.indices.filter {icebergs[$0].hadCollosion}
            return collisions.count == 1 ? collisions.first : nil
        }
        set {
            for index in icebergs.indices {
                icebergs[index].hadCollosion = (index == newValue)
            }
        }
    }
    
    init(numberOfIcebergs: Int) {
        let iceberg = Iceberg()
        icebergs = Array(repeating: iceberg, count: numberOfIcebergs)
    }
    
    func calculateMiles() {
        
    }
}
