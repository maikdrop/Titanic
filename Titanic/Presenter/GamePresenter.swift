//
//  GamePresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class GameViewPresenter {
    
    // MARK: - Properties
    private var fileHandler = FileHandler()
    private(set) lazy var player = getPlayer()
    private weak var delegate: GamePresenterDelegate? {
        didSet {
            status = .new
        }
    }
    private(set) var game: TitanicGame! {
        didSet {
           delegate?.gameDidUpdate()
        }
    }
    private(set) var crashCount = 0 {
        didSet {
            if crashCount == 5 {
                status = .reset
            }
        }
    }
    var knots: Int {
        status == .end || status == .reset ? 0 : 50 - crashCount * 5
    }
    private(set) var drivenSeaMiles = 0.0
    private var seaMilesPerSecond: Double {
        (Double(knots) / 60)/60
    }
    
    private(set) var status: GameStatus? {
        didSet {
            switch status {
                case .new:
                    initScoreValues()
                    delegate?.gameDidStart()
                case .pause:
                    delegate?.gameDidPause()
                case .resume:
                    delegate?.gameDidResume()
                case .reset:
                    game?.resetAllIcebergsVerticallyAndHorizontally()
                    delegate?.gameDidUpdate()
                    delegate?.gameDidReset()
                case .end:
                    game?.resetAllIcebergsVerticallyAndHorizontally()
                    delegate?.gameDidUpdate()
                    endOfGame()
                default:
                    break
            }
        }
    }
    
    
    // MARK: - Creating a Game Presenter
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: (width: Double, height: Double)) {
        game = TitanicGame(icebergInitXOrigin: icebergInitXOrigin, icebergInitYOrigin: icebergInitYOrigin, icebergSize: icebergSize)
    }
    
    deinit {
        print("DEINIT GamePresenter")
    }
}

  // MARK: - Public API
extension GameViewPresenter {
    
    enum GameStatus {
        case new
        case pause
        case resume
        case reset
        case end
        
        static var all: [GameStatus] {
            [GameStatus.new, .pause, .resume, .reset, .end]
        }
        
        var stringValue: String {
            switch self {
                case .new: return AppStrings.GameStatus.new
                case .pause: return AppStrings.GameStatus.pause
                case .resume: return AppStrings.GameStatus.resume
                case .reset: return AppStrings.GameStatus.reset
                case .end: return AppStrings.GameStatus.end
            }
        }
        
        var list: [GameStatus] {
            switch self {
                case .new, .resume: return [.new, .pause, .reset]
                case .pause: return [.resume]
                case .reset, .end: return [.new]
            }
        }
    }
    
    func changeGameStatus(to newStatus: GameStatus) {
        if newStatus == .new {
            status = .reset
            status = .new
        } else {
            status = newStatus
        }
    }
    
    func moveIcebergFromTopToBottom() {
        drivenSeaMiles += seaMilesPerSecond
        drivenSeaMiles = drivenSeaMiles.round(to: 2)
        let factor = 6 - Double(crashCount) * 0.5
        game?.moveIcebergVertically(by: factor)
        delegate?.gameDidUpdate()
    }
    
    func icebergReachedBottom(at index: Int) {
        game?.resetIcebergVertically(at: index)
    }
    
    func intersectionOfShipAndIceberg() {
        crashCount += 1
        game?.resetAllIcebergsVerticallyAndHorizontally()
        delegate?.gameDidUpdate()
    }
    
    func nameForHighscoreEntry(userName: String, completion: (Error?) -> ()) {
        guard player != nil else {
            return
        }
        if player!.count == 10 {player!.removeLast()}
        let newPlayer = Player(name: userName, drivenMiles: drivenSeaMiles)
        player!.append(newPlayer)
        player!.sort(by: >)
        fileHandler.savePlayerToFile(player: player!, then: {result in
            if case .failure(let error) = result {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    
    func timerEnded() {
        status = .end
    }
}

private extension GameViewPresenter {
    
    private func setViewDelegate(gameViewDelegate: self) {
        
    }
    
    private func endOfGame(){
        if isInHighscoreList(drivenSeaMiles) {
            delegate?.gameDidEndWithHighscore()
        } else {
            delegate?.gameDidEndWithoutHighscore()
        }
    }
    
    private func initScoreValues() {
        crashCount = 0
        drivenSeaMiles = 0.0
    }
    
    private func isInHighscoreList(_ drivenSeaMiles: Double) -> Bool {
        guard player != nil else {
            return false
        }
        if player!.count < 10 {
            return true
        } else if player!.count == 10, let drivenSeaMilesOfLastPlayer = player?.last?.drivenMiles {
            if drivenSeaMilesOfLastPlayer < drivenSeaMiles {
                return true
            }
        }
        return false
    }
    
    private func getPlayer() -> [Player]? {
        var playerList: [Player]?
        fileHandler.loadPlayerFile(then: {(result) in
            if case .success(let player) = result {
                playerList = player
            } else {
                playerList = nil
            }
        })
        return playerList
    }
}
