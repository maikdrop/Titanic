//
//  Score.swift
//  Titanic
//
//  Created by Maik on 17.11.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import CoreData

class ScoreObject: NSManagedObject {

    /**
    Creates an database score object.
     
     - Parameter game: ship belongs to
     - Parameter crashCount: current crash count of the game
     - Parameter drivenSeaMiles: current crash count of the game
     - Parameter context: context of game
     */
    static func createScore(for game: GameObject, crashCount: Int, drivenSeaMiles: Double, in context: NSManagedObjectContext) -> ScoreObject {

        let score = ScoreObject(context: context)
        score.game = game
        score.crashCount = Int32(crashCount)
        score.drivenSeaMiles = drivenSeaMiles
        return score
    }
}
