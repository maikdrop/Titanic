/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import Combine
import UIKit

class GameViewPresenter {

    // MARK: - Properties
    private var game: TitanicGame!
    private var cancellableObserver: Cancellable?
    private weak var gameViewDelegate: GameViewDelegate?

    private(set) var gameStatus: GameStatus? {
        didSet {
            switch gameStatus {
            case .new:
                game.startNewTitanicGame()
                gameViewDelegate?.gameDidStart()
                gameStatus = .running
            case .pause:
                gameViewDelegate?.gameDidPause()
            case .resume:
                gameViewDelegate?.gameDidResume()
                gameStatus = .running
            case .end:
                gameViewDelegate?.gameDidUpdate()
                game.drivenSeaMilesInHighscoreList == true ?
                    gameViewDelegate?.gameEndedWithHighscore() : gameViewDelegate?.gameEndedWithoutHighscore()
            default:
                break
            }
        }
    }

    // MARK: - Access to the Model
    var icebergsToDisplay: [CGPoint] {
        var center = [CGPoint]()
        game.icebergs.forEach {iceberg in
            center.append(CGPoint(x: iceberg.center.xCoordinate, y: iceberg.center.yCoordinate))
        }
        return center
    }
    var knots: Int {
        gameStatus == .running ? game.knots : 0
    }
    var drivenSeaMiles: Double {
        game.drivenSeaMiles
    }
    var crashCount: Int {
        game.crashCount
    }
    var countdownBeginningValue: Int {
        game.countdownBeginningValue
    }

    // MARK: - Creating a GameView Presenter and Titanic Game Object
    init(icebergs: [ImageView]) {
        game = createGameModel(from: icebergs)
        setupSubscriberForGameEnd()
    }

    deinit {
        cancellableObserver?.cancel()
        print("DEINIT GameViewPresenter")
    }
}

  // MARK: - Public API: Intents
extension GameViewPresenter {

    func setGameViewDelegate(gameViewDelegate: GameViewDelegate?) {
        self.gameViewDelegate = gameViewDelegate
    }

    func changeGameStatus(to newStatus: String) {
        gameStatus = GameStatus(string: newStatus)
    }

    /**
     While game is running iceberg is moving vertically.
     */
    func moveIcebergsVertically() {
        if gameStatus == .running {
            game?.moveIcebergsVertically()
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running it will be detected that an iceberg reached the end of view.
     */
    func endOfViewReachedFromIceberg(at index: Int) {
        if gameStatus == .running {
            game?.endOfViewReachedFromIceberg(at: index)
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running it will be detected that there is a collision between ship and iceberg.
     */
    func intersectionOfShipAndIceberg() {
        if gameStatus == .running {
            game.collisionBetweenShipAndIceberg()
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     Saving Player with user name for new highscore entry.
     */
    func nameForHighscoreEntry(userName: String, completion: (Error?) -> Void) {
        game.savePlayer(userName: userName) {error in
             if let error = error {
                completion(error)
             } else {
                completion(nil)
            }
        }
    }

    func countdownEnded() {
        gameStatus = .end
    }
}

// MARK: - Private methods
private extension GameViewPresenter {

    /**
     Receiving notification when game did end.
     */
    private func setupSubscriberForGameEnd() {

        cancellableObserver = NotificationCenter.default.publisher(
            for: .GameDidEnd,
            object: game)
            .sink {[weak self] _ in

                self?.gameStatus = .end
        }
    }

    typealias Iceberg = TitanicGame.Iceberg
    typealias Point = TitanicGame.Iceberg.Point
    typealias Size = TitanicGame.Iceberg.Size

    /**
     Creating new game model.
     
     - Parameter icebergs: icebergs from game view
     
     - Returns: a titanic game
    */
    private func createGameModel(from icebergs: [ImageView]) -> TitanicGame {
        var modelIcebergs = [TitanicGame.Iceberg]()
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
}
