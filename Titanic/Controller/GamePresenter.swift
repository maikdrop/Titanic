//
//  GamePresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

protocol PresenterGameView:class {
    
    var mainView: GameView {get}
    func updateView(from model: Titanic?)
    func startGame()
    func pauseGame()
    func resumeGame()
    func showAlertForHighscoreEntry()
}

class GamePresenter {
    
    private weak var presentingView: PresenterGameView?
    private lazy var startDistanceBetweenIcebergs: [Double] = {
        var array = [Double]()
        for index in 0..<presentingView!.mainView.icebergs.count{
            let distance = Double(index) * Double(presentingView!.mainView.ship.frame.height + presentingView!.mainView.ship.frame.height/2)
            array.append(distance)
        }
        return array
    }()
//    private var drivenSeaMiles = 0.0
    var playerList: [Player]? {
        return game?.players
    }
    private var game: Titanic? {
        didSet {
            if game != nil {
                presentingView?.startGame()
            } else {
                presentingView?.updateView(from: game)
            }
        }
    }
    
    var gameStatus: GameStatus? {
        didSet {
            if let view = presentingView, let status = gameStatus {
                switch status {
                case .new:
                    game = createGameModel()
                case .paused:
                    view.pauseGame()
                case .resumed:
                    view.resumeGame()
                case .canceled:
                    game = nil
                case .end:
                    if verifyHighscoreEntry() {
                        view.showAlertForHighscoreEntry()
                    }
                     game = nil
                }
            }
        }
    }
    
    init(view: PresenterGameView) {
        self.presentingView = view
    }
    
    func calculateDrivenSeaMiles(from knots: Int) -> Double {
        Double(knots) / 60
    }
    
    func moveIcebergAccordingToCrashCount(_ crashCount: Int) {
        let factor = 1.0 - Double(crashCount) * 0.2
        game?.translateIcebergsAcrossYAxis(with: factor)
        presentingView?.updateView(from: game)
        game?.icebergs.enumerated().forEach({iceberg in
            if iceberg.element.origin.y > Double(presentingView!.mainView.frame.height) {
                game?.resetIcebergAcrossYAxis(at: iceberg.offset)
            }
        })
    }
    
    func intersectionWithIceberg(at index: Int) {
        game?.resetIcebergAcrossYAxis(at: index)
        presentingView?.updateView(from: game)
    }
    
    func save(of userName: String, with drivenMiles: Double) {
        game?.savePlayer(userName: userName, drivenMiles: drivenMiles)
    }
}

extension GamePresenter {
    
    enum GameStatus: String {
        case new = "New Game"
        case paused = "Pause"
        case resumed = "Resume"
        case canceled = "Cancel"
        case end = "End"
        
        static var all = [GameStatus.new, .paused, .resumed, .canceled, .end]
        
        var list: [GameStatus] {
            switch self {
            case .new, .resumed: return [.new, .paused, .canceled]
            case .paused: return [.new, .resumed, .canceled]
            case .canceled, .end: return [.new]
            }
        }
    }
    
    private func verifyHighscoreEntry() -> Bool {
        if playerList != nil, playerList!.count == 10 {
                if let lastPlayerInList = playerList!.last {
                    //TODO drivenSeaMiles
                    return lastPlayerInList.drivenMiles < 0.0
                }
            return true
        }
        return false
    }

    
    private func createGameModel() -> Titanic? {
        
        var icebergOrigin = [(x: Double, y: Double)]()
        var icebergSize =  [(width: Double, height: Double)]()
        if let view = presentingView {
            view.mainView.icebergs.forEach({ iceberg in
                let randomIndex = startDistanceBetweenIcebergs.index(startDistanceBetweenIcebergs.startIndex, offsetBy: startDistanceBetweenIcebergs.count.arc4random)
                icebergOrigin.append((Double(iceberg.frame.minX), 0 - startDistanceBetweenIcebergs.remove(at: randomIndex)))
                icebergSize.append((Double(iceberg.imageSize.width), Double(iceberg.imageSize.height)))
            })
            return Titanic(numberOfIcebergs: view.mainView.icebergs.count, icebergOrigin: icebergOrigin, icebergSize: icebergSize)
        }
        return nil
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

