//
//  GamePresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

protocol GamePresenterDelegate:class {

    func gameDidUpdate()
    func gameDidStart()
    func gameDidPause()
    func gameDidResume()
    func gameDidReset()
    func gameDidEndWithHighscore()
    func gameDidEndWithoutHighscore()
}

class GamePresenter {
    
    weak var delegate: GamePresenterDelegate? {
        didSet {
            gameStatus = .new
        }
    }
    private(set) var game: Titanic! {
        didSet {
           delegate?.gameDidUpdate()
        }
    }
    private(set) var crashCount = 0 {
        didSet {
            if crashCount == 5 {
                gameStatus = .reset
            }
        }
    }
    var knots: Int {
        gameStatus == .end || gameStatus == .reset ? 0 : 50 - crashCount * 5
    }
    private(set) var drivenSeaMiles = 0.0
    private var seaMilesPerSecond: Double {
        (Double(knots) / 60)/60
    }
    
    private(set) var gameStatus: GameStatus? {
        didSet {
            switch gameStatus {
            case .new:
                initScoreValues()
                delegate?.gameDidStart()
            case .pause:
                delegate?.gameDidPause()
            case .resume:
                delegate?.gameDidResume()
            case .reset:
                game?.resetIcebergsToInitPosition()
                delegate?.gameDidUpdate()
                delegate?.gameDidReset()
            case .end:
                game?.resetIcebergsToInitPosition()
                delegate?.gameDidUpdate()
                endOfGame()
            default:
                break
            }
        }
    }
    
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: (width: Double, height: Double)) {
        game = Titanic(icebergInitXOrigin: icebergInitXOrigin, icebergInitYOrigin: icebergInitYOrigin, icebergSize: icebergSize)
    }
    
    deinit {
        print("DEINIT GamePresenter")
    }
    
    func changeGameStatus(to newStatus: GameStatus) {
        if newStatus == .new {
            gameStatus = .reset
            gameStatus = .new
        } else {
             gameStatus = newStatus
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
        game?.resetIceberg(at: index)
    }
    
    func intersectionOfShipAndIceberg() {
        crashCount += 1
        game?.resetAllIcebergsAfterCollisionWithShip()
        delegate?.gameDidUpdate()
    }
    
    func nameForHighscoreEntry(userName: String) {
        game?.savePlayerInHighscoreList(userName: userName, drivenSeaMiles: drivenSeaMiles)
        delegate?.gameDidUpdate()
    }
    
    func timerEnded() {
        gameStatus = .end
    }
    
}

extension GamePresenter {
    
    enum GameStatus: String {
        case new = "New"
        case pause = "Pause"
        case resume = "Resume"
        case reset = "Reset"
        case end = "End"
        
        static var all: [GameStatus] {
            [GameStatus.new, .pause, .resume, .reset, .end]
        }
        
        var list: [GameStatus] {
            switch self {
                case .new, .resume: return [.new, .pause, .reset]
                case .pause: return [.resume]
                case .reset, .end: return [.new]
            }
        }
    }
    
    private func endOfGame(){
        if game.isInHighscoreList(drivenSeaMiles) {
              delegate?.gameDidEndWithHighscore()
        } else {
             delegate?.gameDidEndWithoutHighscore()
        }
    }
    
    private func initScoreValues() {
        crashCount = 0
        drivenSeaMiles = 0.0
    }
}

