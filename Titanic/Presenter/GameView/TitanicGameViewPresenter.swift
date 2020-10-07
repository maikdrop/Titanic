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

    // MARK: - Properties
    private var game: TitanicGame? {
        didSet {
            gameState = .new
            setupSubscriberForGameEnd()
        }
    }
    private var cancellableObserver: Cancellable?
    private weak var titanicGameViewPresenterDelegate: TitanicGameViewPresenterDelegate?

    private(set) var gameState: GameState? {
        didSet {
            switch gameState {
            case .new:
                game?.startNewTitanicGame()
                titanicGameViewPresenterDelegate?.gameDidStart()
                gameState = .running
            case .pause:
                titanicGameViewPresenterDelegate?.gameDidPause()
            case .resume:
                titanicGameViewPresenterDelegate?.gameDidResume()
                gameState = .running
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
        game?.icebergs.forEach {iceberg in
            let center = IcebergData(xCenter: iceberg.center.xCoordinate, yCenter: iceberg.center.yCoordinate)
            icebergCenter.append(center)
        }
        return icebergCenter
    }
    var knots: Int {
        gameState == .running ? (game?.knots ?? 0) : 0
    }
    var drivenSeaMiles: Double {
        game?.drivenSeaMiles ?? 0.0
    }
    var crashCount: Int {
        game?.crashCount  ?? 0
    }

    var countdownBeginningValue: Int {
         game?.countdownBeginningValue ?? 0
    }
    var icebergsInARow: Int {
        TitanicGame.icebergsInARow
    }
    var rowsOfIcebergs: Int {
        TitanicGame.rowsOfIcebergs
    }

    deinit {
        cancellableObserver?.cancel()
        print("DEINIT TitanicGamePresenter")
    }

     // MARK: - Public Intents

    /**
     Attaches the game view to the game view presenter to use the delegate methods.
     */
    func attachView(_ view: TitanicGameViewPresenterDelegate) {
        titanicGameViewPresenterDelegate = view
    }

    /**
     When the game view did load, the game will be created and started.
     
     - Parameter icebergs: icebergs from GameView
     */
    func gameViewDidLoad(icebergs: [ImageView]) {
        game = createGameModel(from: icebergs)
    }

    /**
     Changes the state of the game.
     
     - Parameter newState: new state of game
     */ 
    func changeGameState(to newState: String) {
        gameState = GameState(string: newState)
    }

    /**
     While the game is running, the icebergs are moving vertically.
     */
    func moveIcebergsVertically() {
        if gameState == .running {
            game?.moveIcebergsVertically()
            titanicGameViewPresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     While the game is running, it will be detected that an iceberg reached the end of view.
     
     - Parameter index: index of iceberg in array
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
     Saves a player with user name as new highscore entry.
     
     - Parameter userName: name of user
     - Parameter completion: completion handler is called when player was saved
     */
    func nameForHighscoreEntry(userName: String, completion: @escaping (Error?) -> Void) {
        game?.savePlayer(userName: userName) {error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func countdownEnded() {
        gameState = .end
    }
}

// MARK: - Model creation and configuration
private extension TitanicGameViewPresenter {

    typealias Iceberg = TitanicGame.Iceberg
    typealias Point = TitanicGame.Iceberg.Point
    typealias Size = TitanicGame.Iceberg.Size

    /**
     Creates a new game model.
     
     - Parameter icebergs: icebergs from game view
     
     - Returns: a titanic game
     */
    private func createGameModel(from icebergs: [ImageView]) -> TitanicGame {
        var modelIcebergs = [Iceberg]()
        icebergs.forEach {icebergView in
            let point = Point(
                xCoordinate: Double(icebergView.frame.origin.x),
                yCoordinate: Double(icebergView.frame.origin.y))
            let size = Size(
                width: Double(icebergView.frame.size.width),
                height: Double(icebergView.frame.size.height))
            let iceberg = Iceberg(origin: point, size: size)
            modelIcebergs.append(iceberg)
        }
        let playerHandler = PlayerHandling(fileName: AppStrings.Highscore.fileName)
        return TitanicGame(icebergs: modelIcebergs, dataHandler: playerHandler)
    }

    /**
     Notifications will be send to the notification center when the game is over.
     */
    private func setupSubscriberForGameEnd() {

        cancellableObserver = NotificationCenter.default.publisher(
            for: .GameDidEnd,
            object: game)
            .sink {[weak self] _ in

                self?.gameState = .end
        }
    }
}
