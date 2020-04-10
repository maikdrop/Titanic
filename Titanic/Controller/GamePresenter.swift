//
//  GamePresenter.swift
//  Titanic
//
//  Created by Maik on 07.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

protocol PresenterGameView:class {
    
    var drivenMiles: Double {get}
    func updateView(from model: Titanic)
    func newView()
    func resetView()
    func showAlert()
}

class GamePresenter {
    
    private weak var view: PresenterGameView?
    private var icebergStartPositions = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
    private var highscoreList = [Player]()
    private var game = Titanic(numberOfIcebergs: 10)
    
    var gameStatus: Titanic.GameStatus = .new {
        didSet {
            switch gameStatus {
            case .new:
                game = Titanic(numberOfIcebergs: 10)
                view?.newView()
            case .paused:
                 //TODO
                print()
            case .resumed:
                 //TODO
                print()
            case .canceled:
                view?.resetView()
            case .end:
                if verify(of: view!.drivenMiles) {
                    view?.showAlert()
                }
            }
        }
    }
    
    init(view: PresenterGameView) {
        self.view = view
    }
    
    func verify(of drivenMiles: Double) -> Bool {
        if let highscoreList = HelperFunctions.getHighscoreList() {
            self.highscoreList = highscoreList
            if self.highscoreList.count == 10 {
                if let lastPlayerInList = self.highscoreList.last, lastPlayerInList.drivenMiles < drivenMiles {
                    self.highscoreList.removeLast()
                }
            }
            return true
        }
        return false
    }
    
    func save(of userName: String, with drivenMiles: Double) {
        highscoreList.append(Player(name: userName, drivenMiles: drivenMiles))
        highscoreList.sort(by: >)
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(highscoreList), forKey: "Highscorelist")
    }
    
    func collosionOfShipWithIceberg(at index: Int) {
        
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



//    init(shipPosition: Point, shipSize: Size, icebergSize: Size, screenWidth: Double ) {
//        ship = MovingObject(origin: shipPosition, size: shipSize)
//        for _ in 0..<10 {
//            var icebergStartPosition = Point()
//            icebergStartPosition.x = screenWidth/icebergStartPositions.remove(at: icebergStartPositions.count.arc4random)
//            icebergStartPosition.y -= icebergSize.height
//            icebergs.append(MovingObject(origin: icebergStartPosition, size: icebergSize))
//        }
//    }
