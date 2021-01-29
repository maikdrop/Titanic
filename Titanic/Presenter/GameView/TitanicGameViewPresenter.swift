/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import Combine

class TitanicGameViewPresenter {

    typealias Option = TitanicGame.SpeedOption
    typealias Score = TitanicGame.Score

    // MARK: - Properties
    private var game: TitanicGame?
    private var initialModelIcebergs: [Iceberg]?
    private var cancellableObserver: Cancellable?
    private let dbHandler = GameHandling()
    private var storingDate: Date?
    private(set) var gameConfig: GameConfig!

    private weak var titanicGameViewPresenterDelegate: TitanicGameViewPresenterDelegate?

    private(set) var gameState: GameState? {
        didSet {
            switch gameState {
            case .new:
                gameConfig = createGameConfig()
                createGame()
                gameState = .preparation
                titanicGameViewPresenterDelegate?.gameDidPrepare()
            case .pause:
                titanicGameViewPresenterDelegate?.gameDidPause()
            case .resume:
                gameState = .running
                titanicGameViewPresenterDelegate?.gameDidResume()
            case .end:
                titanicGameViewPresenterDelegate?.gameDidUpdate()
                game?.drivenSeaMilesInHighscoreList == true ?
                    titanicGameViewPresenterDelegate?.gameEndedWithHighscore() :
                    titanicGameViewPresenterDelegate?.gameEndedWithoutHighscore()
            default:
                break
            }
        }
    }

    // MARK: - Access to the Model
    var icebergsToDisplay: [IcebergData] {
        var icebergCenter = [IcebergData]()
        game?.icebergs.forEach { iceberg in
            let center = IcebergData(xCenter: iceberg.center.xCoordinate, yCenter: iceberg.center.yCoordinate)
            icebergCenter.append(center)
        }
        return icebergCenter
    }
    var knots: Int {
        gameState == .running ? (game?.score.knots ?? 0) : 0
    }
    var drivenSeaMiles: Double {
        game?.score.drivenSeaMiles ?? 0.0
    }
    var crashCount: Int {
        game?.score.crashCount ?? 0
    }
    var icebergsInARow: Int {
        TitanicGame.icebergsInARow
    }
    var rowsOfIcebergs: Int {
        TitanicGame.rowsOfIcebergs
    }

    init(storingDate: Date?) {
        self.storingDate = storingDate
    }

    deinit {
        cancellableObserver?.cancel()
        print("DEINIT TitanicGamePresenter")
    }

    // MARK: - Public User Intents

    /**
     Attaches the game view to the game view presenter to use the delegate methods.
     */
    func attachView(_ view: TitanicGameViewPresenterDelegate) {
        titanicGameViewPresenterDelegate = view
    }

    /**
     When the game view did load, a new game will be created.
     
     - Parameter icebergs: The icebergs from the game view.
     */
    func gameViewDidLoad(icebergs: [ImageView]) {
        setupSubscriberForGameEnd()
        prepareGame(from: icebergs)
        gameState = .new
    }

    /**
     When the preparation of the game view ended, the new game will be started.
     */
    func viewPreparationEnded() {
        gameState = .running
        titanicGameViewPresenterDelegate?.gameDidStart()
    }

    /**
     Changes the state of the game.
     
     - Parameter newState: The new state of the game.
     */ 
    func changeGameState(to newState: String) {
        gameState = GameState(string: newState)
    }

    /**
     Changes the state of the game.
     
     - Parameter newState: The new state of the game.
     */ 
    func changeGameState(to newState: GameState) {
        gameState = newState
    }

    /**
     While the game is running, the icebergs are moving vertically.
     */
    func moveIcebergsVertically() {
        if gameState == .running {
            game?.moveIcebergsVertically(with: gameConfig.speedFactor)
            titanicGameViewPresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     While the game is running, it will be detected that an iceberg reached the end of view.
     
     - Parameter index: The index of the iceberg in the array.
     */
    func endOfViewReachedFromIceberg(at index: Int) {
        if gameState == .running {
            game?.endOfViewReachedFromIceberg(at: index)
            titanicGameViewPresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     While the game is running, collisions between ship and icebergs will be detected.
     */
    func intersectionOfShipAndIceberg() {
        if gameState == .running {
            game?.collisionBetweenShipAndIceberg()
            titanicGameViewPresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     Get a value for a slider within a range.
     
     - Parameter min: The minimum value of the range.
     - Parameter max: The maximum value o the range.
     
     - Returns: a slider value
     */
    func getSliderValue(within min: Float, and max: Float) -> Float {
        gameConfig.sliderValue ?? Float.random(in: min...max)
    }

    /**
     Saves a player with user name as new highscore entry.
     
     - Parameter userName: The user`s name.
     - Parameter completion: The completion handler that calls back when saving the player was successful or not.
     */
    func nameForHighscoreEntry(userName: String, completion: (Error?) -> Void) {
        game?.savePlayer(userName: userName) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    /**
     Saves the game and calls back if saving was successful or not.
     
     - Parameter sliderValue: The slider`s current value.
     - Parameter timerCount: The game`s timer count.
     - Parameter completion: The completion handler that calls back when saving the game was successful or not.
     */
    func saveGame(sliderValue: Float, timerCount: Int, completion: (Error?) -> Void) {
        gameState = .save
        gameConfig.sliderValue = sliderValue
        gameConfig.timerCount = timerCount
        if let gameToSave = game {
            dbHandler.updateDatabase(icebergs: gameToSave.icebergs,
                                     score: gameToSave.score,
                                     gameConfig: gameConfig) { result in
                if case .failure(let error) = result {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }

    func countdownEnded() {
        gameState = .end
    }
}

// MARK: - Private methods for model and db handling
private extension TitanicGameViewPresenter {

    typealias Iceberg = TitanicGame.Iceberg
    typealias Point = TitanicGame.Iceberg.Point
    typealias Size = TitanicGame.Iceberg.Size

    /**
     Creates the initial model icebergs from the game view icebergs.
     
     - Parameter icebergs: The icebergs from the game view.
     */
    private func prepareGame(from icebergs: [ImageView]) {
        var modelIcebergs = [Iceberg]()
        icebergs.forEach { icebergView in
            let point = Point(
                xCoordinate: Double(icebergView.frame.origin.x),
                yCoordinate: Double(icebergView.frame.origin.y))
            let size = Size(
                width: Double(icebergView.frame.size.width),
                height: Double(icebergView.frame.size.height))
            let iceberg = Iceberg(origin: point, size: size)
            modelIcebergs.append(iceberg)
        }
        self.initialModelIcebergs = modelIcebergs
    }

    /**
     Creates a default game or a stored game in order to continue the game.
     */
    private func createGame() {
        if let modelIcebergs = initialModelIcebergs {
            let playerHandler = PlayerHandling(fileName: AppStrings.Highscore.fileName)
            if let date = storingDate {
                storingDate = nil
                game = createGameModel(at: date, from: modelIcebergs, playerHandler: playerHandler)
                dbHandler.deleteGame(matching: date, then: nil)
            } else {
                game = createGameModel(from: modelIcebergs, playerHandler: playerHandler)
            }
        }
    }

    /**
     Creates the default game model.
     
     - Parameter initialIcebergs: The initial iceberg data from the game view.
     - Parameter playerHandler: Handles the data flow between model and player storage.
     
     - Returns: a titanic game
     */
    private func createGameModel(from initialIcebergs: [Iceberg], playerHandler: PlayerHandling) -> TitanicGame? {
        if let beginningKnots = Option(rawValue: gameConfig.speedFactor)?.knots {
            let score = Score(beginningKnots: beginningKnots)
            return TitanicGame(initialIcebergs: initialIcebergs, score: score, dataHandler: playerHandler)
        }
        return nil
    }

    /**
     Creates a game model from database data.
     
     - Parameter date: The storage date of the game.
     - Parameter initialIcebergs: The initial iceberg data from the game view.
     - Parameter playerHandler: Handles the data flow between model and player storage.
     
     - Returns: a titanic game
     */
    private func createGameModel(at date: Date, from initialIcebergs: [Iceberg], playerHandler: PlayerHandling) -> TitanicGame? {

        if let fetchedGame = fetchGame(matching: date), let fetchedPos = getIcebergPosFrom(fetchedGame: fetchedGame),
           let fetchedScore = fetchedGame.score, let gameConfig = fetchedGame.config {
            self.gameConfig.sliderValue = gameConfig.sliderValue
            self.gameConfig.timerCount = Int(gameConfig.timerCount)
            self.gameConfig.speedFactor = Int(gameConfig.moveFactor)
            let speedOption = Option(rawValue: Int(gameConfig.moveFactor)) ?? Option.medium
            let score = TitanicGame.Score(drivenSeaMiles: fetchedScore.drivenSeaMiles,
                                          beginningKnots: speedOption.knots,
                                          crashCount: Int(fetchedScore.crashCount))
            return TitanicGame(initialIcebergs: initialIcebergs,
                               score: score,
                               dataHandler: playerHandler,
                               fetchedCenterPos: fetchedPos)
        }
        return nil
    }

    /**
     Fetches the game that based on a date.
     
     - Parameter date: The storage date of the game that is being searched for in the data base.
     
     - Returns: the fetched game from the database
     */
    private func fetchGame(matching date: Date) -> GameObject? {
        var fetchedGame: GameObject?
        dbHandler.fetchFromDatabase(matching: date) { result in
            if case .success(let game) = result {
                fetchedGame = game
            }
        }
        return fetchedGame
    }

    /**
     Extracts the stored coordinates of the icebergs from a fetched game.
     
     - Parameter fetchedGame: A fetched game from the database.
     
     - Returns: the stored iceberg coordinates
     */
    private func getIcebergPosFrom(fetchedGame: GameObject) -> [TitanicGame.Iceberg.Point]? {

        if let fetchedIcebergs = fetchedGame.icebergs?.allObjects as? [IcebergObject] {
            var icebergPositions = [TitanicGame.Iceberg.Point]()
            fetchedIcebergs.forEach { iceberg in
                icebergPositions.append(
                    TitanicGame.Iceberg.Point(xCoordinate: iceberg.centerX,
                                              yCoordinate: iceberg.centerY))
            }
            return icebergPositions
        }
        return nil
    }
}

// MARK: - Private utility methods
private extension TitanicGameViewPresenter {

    /**
     Receives notifications when the game is over.
     */
    private func setupSubscriberForGameEnd() {

        cancellableObserver = NotificationCenter.default.publisher(
            for: .GameDidEnd,
            object: game)
            .sink {[weak self] _ in

                self?.gameState = .end
        }
    }

    /**
     Creates the default standard configuration for the titanic game.
     
     - Returns: a game configuration
     */
    private func createGameConfig() -> GameConfig {
        let speedKey = AppStrings.UserDefaultKeys.speed
        var speedFactor = Option.medium.rawValue
        if let speed = UserDefaults.standard.value(forKey: speedKey) as? Int {
            speedFactor = speed
        }
        return GameConfig(timerCount: defaultTimerCount, speedFactor: speedFactor)
    }
}

// MARK: - Constants
private extension TitanicGameViewPresenter {

    private var defaultTimerCount: Int { 60 }
}
