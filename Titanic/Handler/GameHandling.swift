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
     Fetches game data from database.
     
     - Parameter date: date of a saved game
     - Parameter completion: completion handler is called when data was fetched
     */
    func fetchFromDatabase(matching date: Date, then completion: (Handler)) {

        if let context = container?.viewContext {
            do {
                let game = try GameObject.findGame(matching: date, in: context)
                completion(.success(game))
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                        message: AppStrings.ErrorAlert.databaseReadingErrorMessage)))
            }
        }
    }

    /**
     Updates database.
     
     - Parameter icebergs: icebergs to save
     - Parameter score: score to save
     - Parameter sliderValue: slider value to save
     - Parameter currentCountdown: timer countdown count to save
     - Parameter completion: completion handler calls back when data was saved
     */
    func updateDatabase(icebergs: [TitanicGame.Iceberg],
                        score: TitanicGame.Score,
                        sliderValue: Float,
                        currentCountdown: Int,
                        then completion: (Handler)) {

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
     Delete game data from database.
     
     - Parameter game: game object
     - Parameter completion: completion handler is called when game was deleted from database
     */
    func deleteGame(game: GameObject, then completion: (Handler)) {

        if let context = container?.viewContext {

            context.delete(game)

            do {
                try context.save()
                completion(.success(game))
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                        message: AppStrings.ErrorAlert.databaseDeletingErrorMessage)))
            }
        }
    }

    /**
     Delete game from database.
     
     - Parameter date: date of saved game that will be deleted
     - Parameter completion: completion handler is called when game was deleted from datase
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
                                        message: AppStrings.ErrorAlert.databaseDeletingErrorMessage)))
            }
        }
    }
}
