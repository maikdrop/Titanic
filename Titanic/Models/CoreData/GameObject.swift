//
//  GameObject.swift
//  Titanic
//
//  Created by Maik on 17.11.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import CoreData

class GameObject: NSManagedObject {

    /**
     Finds a game in the databasse based on a date.
     
     - Parameter date: date of saved game that is being searched for
     - Parameter context: context of game
     
     - Returns: a game object
     */
    static func findGame(matching date: Date, in context: NSManagedObjectContext) throws -> GameObject? {

        let request: NSFetchRequest<GameObject> = GameObject.fetchRequest()
        request.predicate = NSPredicate(format: "stored = %@", date as NSDate)

        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                assert(matches.count == 1, "Game.findGame -- database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        return nil
    }

    /**
     Finds an undefind game in the databasse.
     
     - Parameter context: context of game
     
     - Returns: a game object
     */
    static func findGame(in context: NSManagedObjectContext) throws -> GameObject? {

        let request: NSFetchRequest<GameObject> = GameObject.fetchRequest()

        do {
            let matches = try context.fetch(request)
            if !matches.isEmpty {
                return matches[0]
            }
        } catch {
            throw error
        }
        return nil
    }

    /**
    Creates and stores a game into the database.
     
     - Parameter icebergs: icebergs to save
     - Parameter score: score to save
     - Parameter sliderValue: sliderValue to save
     - Parameter currentCountdown: timer countdown count to save
     - Parameter context: context of game
     
     - Returns: a game object
     */
    static func createAndStoreGame(icebergs: [TitanicGame.Iceberg],
                                   score: TitanicGame.Score,
                                   sliderValue: Float,
                                   currentCountdown: Int,
                                   in context: NSManagedObjectContext) -> GameObject {

        let game = GameObject(context: context)
        game.stored = Date()
        game.sliderValue = sliderValue
        game.timerCount = Int32(currentCountdown)
        game.score = ScoreObject.createScore(for: game,
                                             crashCount: score.crashCount,
                                             drivenSeaMiles: score.drivenSeaMiles,
                                             in: context)
        icebergs.forEach { iceberg in
            IcebergObject.createIceberg(for: game,
                                        with: (iceberg.center.xCoordinate, iceberg.center.yCoordinate),
                                        in: context)
        }
        return game
    }
}

extension GameObject {

    /**
     Creates a fetch request for games in a descending order.
     
     - Parameter predicate: predicate of the fetch request
     
     - Returns: a fetch request
     */
    static func fetchGamesRequest(predicate: NSPredicate?) -> NSFetchRequest<GameObject> {
        let request = NSFetchRequest<GameObject>(entityName: "GameObject")
        request.sortDescriptors = [NSSortDescriptor(key: "stored", ascending: false)]
        request.predicate = predicate
        return request
    }
}
