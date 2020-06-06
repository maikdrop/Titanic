//
//  Iceberg.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Point {
    var x = 0.0, y = 0.0
}

struct Size {
    var width = 0.0, height = 0.0
}

struct Iceberg {
    
    var origin = Point()
    var size = Size()
    
    var center: Point {
        get {
            let centerX = origin.x + (size.width / 2)
            let centerY = origin.y + (size.height / 2)
            return Point(x: centerX, y: centerY)
        }
        set(newCenter) {
            origin.x = newCenter.x - (size.width / 2)
            origin.y = newCenter.y - (size.height / 2)
        }
    }
}

extension Iceberg: Comparable {
    
    static func < (lhs: Iceberg, rhs: Iceberg) -> Bool {
        return (lhs.center.y < rhs.center.y)
    }
    
    static func == (lhs: Iceberg, rhs: Iceberg) -> Bool {
        return lhs.center.y == rhs.center.y
    }
}
