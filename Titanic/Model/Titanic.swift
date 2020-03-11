//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Titanic {
    
    private var icebergStartPositions = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    private(set) var icebergs = [MovingObject]()
    private(set) var ship: MovingObject
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
    
    init(shipPosition: Point, shipSize: Size, icebergSize: Size, screenWidth: Double ) {
        ship = MovingObject(origin: shipPosition, size: shipSize)
        for _ in 0..<10 {
            var icebergStartPosition = Point()
            icebergStartPosition.x = screenWidth/icebergStartPositions.remove(at: icebergStartPositions.count.arc4random)
            icebergStartPosition.y -= icebergSize.height
            icebergs.append(MovingObject(origin: icebergStartPosition, size: icebergSize))
        }
    }
    
    mutating func moveIceberg(at index: Int, to newCenter: Point) {
        icebergs[index].center = newCenter
    }
    
    mutating func moveShip(to newCenter: Point) {
        ship.center = newCenter
    }
    
}

extension Int {
    var arc4random: Int {
        if self > 0 {
             return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

