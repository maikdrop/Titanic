//
//  GamePresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

protocol PresenterGameView:class {
    //TODO remove mainView -> add pauseGame(), resumeGame()
    var mainView: GameView {get}
    func updateView(from model: Titanic?)
    func startGame()
    func showAlertForHighscoreEntry()
}

class GamePresenter {
    
    private weak var presentingView: PresenterGameView?
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
                    game = nil
                    game = createGameModel()
                case .paused:
                    //TODO view.pauseGame()
                    view.mainView.countdownTimer.pause()
                case .resumed:
                    view.mainView.countdownTimer.resume()
                case .canceled:
                    game = nil
                case .end:
                    if verifyHighscoreEntry() {
                        view.showAlertForHighscoreEntry()
                    }
                }
            }
        }
    }
    
    init(view: PresenterGameView) {
        self.presentingView = view
    }
    
    deinit {
        print("DEINIT GamePresenter")
    }
    
    func calculateDrivenSeaMiles(from knots: Int) -> Double {
        Double(knots) / 60
    }
    
    func moveIcebergAccordingToCrashCount(_ crashCount: Int) {
        let factor = 1.0 - Double(crashCount) * 0.2
        game?.translateIcebergsAcrossYAxis(with: factor)
        presentingView?.updateView(from: game)
        if presentingView != nil {
            game?.icebergs.enumerated().forEach({iceberg in
                if iceberg.element.origin.y > Double(presentingView!.mainView.frame.height) {
                    game?.loopingIcebergTranslation(at: iceberg.offset)
                    presentingView!.updateView(from: game)
                }
            })
        }
    }
    
    func intersectionOfShipAndIceberg() {
        game?.shipCollisionWithIceberg()
        presentingView?.updateView(from: game)
    }
    
    func save(of userName: String, with drivenMiles: Double) {
        game?.savePlayerInHighscoreList(userName: userName, drivenMiles: drivenMiles)
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

        if playerList != nil {
            if playerList!.count < 10 {
                return true
            } else if playerList!.count == 10 {
                if let drivenSeaMiles = Double(presentingView!.mainView.scoreStack.drivenSeaMilesLbl.text!) {
                     return playerList!.last!.drivenMiles < drivenSeaMiles ? true:false
                }
            }
        }
        return false
    }

    private func createGameModel() -> Titanic? {
        if let view = presentingView {
            let shipHeight = Double(view.mainView.ship.frame.height)
            var icebergSize = (width: 0.0, height: 0.0)
            if let iceberg = view.mainView.icebergs.first {
                icebergSize.width = Double(iceberg.frame.width)
                icebergSize.height = Double(iceberg.frame.height)
            }
            var icebergXOrigin = [Double]()
            view.mainView.icebergs.forEach({ iceberg in
                icebergXOrigin.append((Double(iceberg.frame.minX)))
            })
            return Titanic(icebergXOrigin: icebergXOrigin, icebergSize: icebergSize, shipHeight: shipHeight)
        }
        return nil
    }
}
