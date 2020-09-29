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
            setupSubscriberForGameEnd()
        }
    }
    private var cancellableObserver: Cancellable?
    private weak var titanicGamePresenterDelegate: TitanicGamePresenterDelegate?

    private(set) var gameState: GameState? {
        didSet {
            switch gameState {
            case .new:
                game?.startNewTitanicGame()
                titanicGamePresenterDelegate?.gameDidStart()
                gameState = .running
            case .pause:
                titanicGamePresenterDelegate?.gameDidPause()
            case .resume:
                titanicGamePresenterDelegate?.gameDidResume()
                gameState = .running
            case .end:
                titanicGamePresenterDelegate?.gameDidUpdate()
                game?.drivenSeaMilesInHighscoreList == true ?
                    titanicGamePresenterDelegate?.gameEndedWithHighscore() :
                    titanicGamePresenterDelegate?.gameEndedWithoutHighscore()
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

     // MARK: - Public Game Intents
    /**
     Change the state of the game.
     
     - Parameter newState: new state of game
     */ 
    func changeGameState(to newState: String) {
        gameState = GameState(string: newState)
    }

    /**
     While game is running iceberg is moving vertically.
     */
    func moveIcebergsVertically() {
        if gameState == .running {
            game?.moveIcebergsVertically()
            titanicGamePresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running it will be detected that an iceberg reached the end of view.
     
     - Parameter index: index of iceberg in array
     */
    func endOfViewReachedFromIceberg(at index: Int) {
        if gameState == .running {
            game?.endOfViewReachedFromIceberg(at: index)
            titanicGamePresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running collisions between ship and iceberg will be detected.
     */
    func intersectionOfShipAndIceberg() {
        if gameState == .running {
            game?.collisionBetweenShipAndIceberg()
            titanicGamePresenterDelegate?.gameDidUpdate()
        }
    }

    /**
     Saving a player with user name as new highscore entry.
     
     - Parameter userName: name of user
     - Parameter completion: completion handler is called when player was saved
     */
    func nameForHighscoreEntry(userName: String, completion: (Error?) -> Void) {
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

// MARK: - Public API: View-Presenter Configuration
extension TitanicGameViewPresenter {

    /**
     Attaches View to game Presenter for delegate methods.
     */
    func attachView(_ view: TitanicGamePresenterDelegate) {
        titanicGamePresenterDelegate = view
    }

    /**
     When game view did load game will be created and started.
     
     - Parameter icebergs: icebergs from GameView
     */
    func gameViewDidLoad(icebergs: [ImageView]) {
        game = createGameModel(from: icebergs)
        gameState = .new
    }
}

// MARK: - Model creation and configuration
private extension TitanicGameViewPresenter {

    typealias Iceberg = TitanicGame.Iceberg
    typealias Point = TitanicGame.Iceberg.Point
    typealias Size = TitanicGame.Iceberg.Size

    /**
     Creating new game model.
     
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
        return TitanicGame(icebergs: modelIcebergs)
    }

    /**
     Receiving notification when game did end.
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
