//
//  GameViewPresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import Combine

final class GameViewPresenter {

    // MARK: - Properties
    private let fileHandler = FileHandler()
    private(set) lazy var player = getPlayer()

    private(set) var game: TitanicGame!
    private weak var gameViewDelegate: GameViewDelegate?
    private var cancellableObserver: Cancellable?

    private(set) var gameStatus: GameStatus? {
        didSet {
            switch gameStatus {
            case .new:
                game.startNewRound()
                gameViewDelegate?.gameDidStart()
                gameStatus = .running
            case .pause:
                gameViewDelegate?.gameDidPause()
            case .resume:
                gameViewDelegate?.gameDidResume()
                gameStatus = .running
            case .end:
                endOfGame()
            default:
                break
            }
        }
    }

    // MARK: - Creating a GameView Presenter
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: [(width: Double, height: Double)]) {
        game = TitanicGame(
                icebergInitXOrigin: icebergInitXOrigin,
                icebergInitYOrigin: icebergInitYOrigin,
                icebergSize: icebergSize)
        setupSubscriber()
    }

    deinit {
        cancellableObserver?.cancel()
        print("DEINIT GameViewPresenter")
    }
}

  // MARK: - Public API
extension GameViewPresenter {

    func setGameViewDelegate(gameViewDelegate: GameViewDelegate?) {
        self.gameViewDelegate = gameViewDelegate
        gameStatus = .new
    }

    func changeGameStatus(to newStatus: String) {
        gameStatus = GameStatus(string: newStatus)
    }

    func moveIcebergsToScreenEnd() {
        game?.moveIcebergsVertically()
        gameViewDelegate?.gameDidUpdate()
    }

    func reachingEndOfViewOfIceberg(at index: Int) {
        game?.resetIceberg(at: index)
        gameViewDelegate?.gameDidUpdate()
    }

    func intersectionOfShipAndIceberg() {
        game.collisionBetweenShipAndIceberg()
        gameViewDelegate?.gameDidUpdate()
    }

    func nameForHighscoreEntry(userName: String, completion: (Error?) -> Void) {
        guard player != nil else {
            return
        }
        if player!.count == playerCount {player!.removeLast()}
        let newPlayer = TitanicGame.Player(name: userName, drivenMiles: game.drivenSeaMiles)
        player!.append(newPlayer)
        player!.sort(by: >)
        fileHandler.savePlayerToFile(player: player!) {result in
            if case .failure(let error) = result {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func gameCountdownTimerDidUpdate() {
        game.countdownUpdate()
    }
}

// MARK: - Private methods
private extension GameViewPresenter {

    private func setupSubscriber() {

        cancellableObserver = NotificationCenter.default.publisher(
            for: .GameDidEnd,
            object: game)
            .sink {[weak self] _ in

                self?.gameStatus = .end
        }
    }

    private func endOfGame() {
        if isInHighscoreList(game.drivenSeaMiles) {
            gameViewDelegate?.gameDidEndWithHighscore()
        } else {
            gameViewDelegate?.gameDidEndWithoutHighscore()
        }
    }

    private func isInHighscoreList(_ drivenSeaMiles: Double) -> Bool {
        guard player != nil else {
            return false
        }
        if player!.count < playerCount {
            return true
        } else if player!.count == playerCount, let drivenSeaMilesOfLastPlayer = player?.last?.drivenMiles {
            if drivenSeaMilesOfLastPlayer < drivenSeaMiles {
                return true
            }
        }
        return false
    }

    private func getPlayer() -> [TitanicGame.Player]? {
        var playerList: [TitanicGame.Player]?
        fileHandler.loadPlayerFile {result in
            if case .success(let player) = result {
                playerList = player
            } else {
                playerList = nil
            }
        }
        return playerList
    }
}

// MARK: - Constants
extension GameViewPresenter {
    private var playerCount: Int {10}
}
