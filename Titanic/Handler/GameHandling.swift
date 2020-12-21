//
//  GameHandling.swift
//  Titanic
//
//  Created by Maik on 17.11.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct GameHandling {

    // MARK: - Properties
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    typealias Handler = (Result<GameObject?, Error>) -> Void

    /**
     Fetches game data from the database that is based on a date.
     
     - Parameter date: date of a saved game
     - Parameter completion: completion handler calls back when a game was fetched or if an error occurred
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
     
     - Parameter completion: completion handler calls back when a game was fetched or if an error occurred
     
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
     
     - Parameter icebergs: icebergs to save
     - Parameter score: score to save
     - Parameter sliderValue: slider value to save
     - Parameter currentCountdown: timer countdown count to save
     - Parameter completion: completion handler calls back when data was saved or if an error occurred
     */
    func updateDatabase(icebergs: [TitanicGame.Iceberg],
                        score: TitanicGame.Score,
                        sliderValue: Float,
                        currentCountdown: Int,
                        then completion: (Handler)) {

//        print("SAVE GAME START")
//        print("Save Icebergs")
//        for iceberg in icebergs {
//            print("Center X")
//            print(iceberg.center.xCoordinate)
//            print("Center Y")
//            print(iceberg.center.yCoordinate)
//        }
//        print("Save Slider Value")
//        print(sliderValue)
//        print("Current Countdown")
//        print(currentCountdown)
//        print("Driven Sea Miles")
//        print(score.drivenSeaMiles)
//        print("Knots")
//        print(score.knots)
//        print("CrashCount")
//        print(score.crashCount)
//        print("SAVE GAME END")

        if let context = container?.viewContext {

            do {
                let game = GameObject.createAndStoreGame(icebergs: icebergs,
                                                         score: score,
                                                         sliderValue: sliderValue,
                                                         currentCountdown: currentCountdown,
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
     Delete a game from the database.
     
     - Parameter game: game object
     - Parameter completion: completion handler calls back when the game was deleted from the database or if an error occurred
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
     Delete a game from the database.
     
     - Parameter date: date of saved game that will be deleted
     - Parameter completion: completion handler calls back when the game was deleted from the database or if an error occurred
     */
    func deleteGame(matching date: Date, then completion: (Handler)) {

        if let context = container?.viewContext {
            do {
                if let game = try GameObject.findGame(matching: date, in: context) {
                    context.delete(game)
                    try context.save()
                    completion(.success(game))
                }
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                message: AppStrings.ErrorAlert
                                    .databaseDeletingErrorMessage)))
            }
        }
    }
}
