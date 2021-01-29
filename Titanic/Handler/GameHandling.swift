/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import UIKit
import CoreData

struct GameHandling {

    // MARK: - Properties
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    typealias Handler = (Result<GameObject?, Error>) -> Void

    /**
     Fetches game data from the database based on a date.
     
     - Parameter date: The date of a saved game.
     - Parameter completion: The completion handler that calls back when a game was fetched or if an error occurred.
     */
    func fetchFromDatabase(matching date: Date, then completion: (Handler)) {

        if let context = container?.viewContext {
            do {
                let game = try GameObject.findGame(matching: date, in: context)
                completion(.success(game))
            } catch {
                completion(.failure(DataHandlingError.readingError(
                                        message: AppStrings.ErrorAlert.databaseReadingErrorMessage)))
            }
        }
    }

    /**
     Fetches game data from the database.
     
     - Parameter completion: The completion handler that calls back when a game was fetched or if an error occurred.
     
     - Use this function if you want to check out that the database is empty or not.
     */
    func fetchFromDatabase(then completion: (Handler)) {

        if let context = container?.viewContext {
            do {
                let game = try GameObject.findGame(in: context)
                completion(.success(game))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /**
     Updates the database.
     
     - Parameter icebergs: The icebergs of the game.
     - Parameter score: The game`s score.
     - Parameter gameConfig: The game`s configuration.
     - Parameter completion: The completion handler that calls back when a game was saved or if an error occurred.
     */
    func updateDatabase(icebergs: [TitanicGame.Iceberg],
                        score: TitanicGame.Score,
                        gameConfig: TitanicGameViewPresenter.GameConfig,
                        then completion: (Handler)) {

        if let context = container?.viewContext {

            do {
                let game = GameObject.createGame(
                    icebergs: icebergs,
                    score: score,
                    gameConfig: gameConfig,
                    in: context)
                try context.save()
                completion(.success(game))
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                        message: AppStrings.ErrorAlert.databaseWritingErrorMessage)))
            }
        }
    }

    /**
     Delete games from the database.
     
     - Parameter games: The games to delete.
     - Parameter completion: The completion handler that calls back when the games were deleted or if an error occurred.
     */
    func delete(games: [GameObject], then completion: (Handler)) {

        if let context = container?.viewContext {

            games.forEach { game in
                context.delete(game)
            }

            do {
                try context.save()
                completion(.success(nil))
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                        message: AppStrings.ErrorAlert.databaseDeletingErrorMessage)))
            }
        }
    }

    /**
     Deletes a game from the database based on a date.
     
     - Parameter date: The storage date of the game that will be deleted.
     - Parameter completion: The completion handler that calls back when a game was deleted or if an error occurred.
     */
    func deleteGame(matching date: Date, then completion: (Handler?)) {

        if let context = container?.viewContext {
            do {
                if let game = try GameObject.findGame(matching: date, in: context) {
                    context.delete(game)
                    try context.save()
                    if completion != nil {completion!(.success(game))}
                }
            } catch {
                if completion != nil {
                    completion!(.failure(DataHandlingError
                                            .writingError(message: AppStrings.ErrorAlert.databaseDeletingErrorMessage)))
                }
            }
        }
    }
}
