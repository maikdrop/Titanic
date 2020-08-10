//
//  Iceberg.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Iceberg {

    // MARK: - Properties
    var origin = Point()
    var size = Size()

    var center: Point {
        get {
            let centerX = origin.xCoordinate + (size.width / 2)
            let centerY = origin.yCoordinate + (size.height / 2)
            return Point(xCoordinate: centerX, yCoordinate: centerY)
        }
        set(newCenter) {
            origin.xCoordinate = newCenter.xCoordinate - (size.width / 2)
            origin.yCoordinate = newCenter.yCoordinate - (size.height / 2)
        }
    }
}

// MARK: - Implementation Comparable Protocol
extension Iceberg: Comparable {

    static func < (lhs: Iceberg, rhs: Iceberg) -> Bool {
        return (lhs.center.yCoordinate < rhs.center.yCoordinate)
    }

    static func == (lhs: Iceberg, rhs: Iceberg) -> Bool {
        return lhs.center.yCoordinate == rhs.center.yCoordinate
    }
}
