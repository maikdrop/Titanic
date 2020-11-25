//
//  IcebergObject.swift
//  Titanic
//
//  Created by Maik on 17.11.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import CoreData

class IcebergObject: NSManagedObject {

    /**
    Creates an database iceberg object.
     
     - Parameter game: iceberg belongs to
     - Parameter center: center coordinates of the iceberg
     - Parameter context: context of game
     */
    static func createIceberg(for game: GameObject, with center: (x: Double, y: Double), in context: NSManagedObjectContext) {

        let iceberg = IcebergObject(context: context)
        iceberg.centerX = center.x
        iceberg.centerY = center.y
        iceberg.game = game
    }
}
