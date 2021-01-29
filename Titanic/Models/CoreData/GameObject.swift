/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import CoreData

class GameObject: NSManagedObject {

    /**
     Finds a game in the databasse based on a date.
     
     - Parameter date: The storage date of the game that is being searched for.
     - Parameter context: The context of the game.
     
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
     
     - Parameter context: The context of the game.
     
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
     
     - Parameter icebergs: The icebergs of the game.
     - Parameter score: The game`s score.
     - Parameter gameConfig: The game`s configuration.
     - Parameter context: The context of the game.
     
     - Returns: a game object
     */
    static func createGame(icebergs: [TitanicGame.Iceberg],
                           score: TitanicGame.Score,
                           gameConfig: TitanicGameViewPresenter.GameConfig,
                           in context: NSManagedObjectContext) -> GameObject {

        let game = GameObject(context: context)
        game.stored = Date()
        game.config = ConfigObject.createConfig(for: game,
                                                timerCount: gameConfig.timerCount,
                                                moveFactor: gameConfig.speedFactor,
                                                sliderValue: gameConfig.sliderValue!,
                                                in: context)
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

// MARK: - Methods for SwiftUI
extension GameObject {

    /**
     Creates a fetch request for all games in a descending order.
     
     - Parameter predicate: The predicate of the fetch request.
     
     - Returns: a fetch request
     */
    static func fetchGamesRequest(predicate: NSPredicate?) -> NSFetchRequest<GameObject> {
        let request = NSFetchRequest<GameObject>(entityName: "GameObject")
        request.sortDescriptors = [NSSortDescriptor(key: "stored", ascending: false)]
        request.predicate = predicate
        return request
    }
}
