//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class Titanic {
    
    private var icebergInitXOrigin = [Double]()
    private var icebergInitYOrigin = [Double]()
    private var distanceBetweenIcebergs = 0.0
    private var fileHandler = FileHandler()
    private(set) var icebergs = [Iceberg]()
    private(set) lazy var player = getPlayer()
    
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: (width: Double, height: Double)) {
        self.icebergInitXOrigin = icebergInitXOrigin
        self.icebergInitYOrigin = icebergInitYOrigin
        for index in 0..<icebergInitXOrigin.count {
            let origin = Point(x: icebergInitXOrigin[index], y: icebergInitYOrigin[index])
            let size = Size(width: icebergSize.width, height: icebergSize.height)
            let iceberg = Iceberg(origin: origin, size: size)
            icebergs += [iceberg]
        }
        distanceBetweenIcebergs = calculateDistanceBetweenIcebergs()
        shuffleIcebergVertically(at: Array(icebergs.indices))
    }
    
    deinit {
        print("DEINIT Titanic")
    }
    
    func moveIcebergVertically(by factor: Double) {
        for index in 0..<icebergs.count {
            icebergs[index].center.y += factor
        }
    }
    
    func resetIceberg(at index: Int) {
        if let icebergWithSmallestY = icebergs.min() {
            icebergs[index].origin.y = icebergWithSmallestY.origin.y - distanceBetweenIcebergs
        }
        shuffleIcebergHorizontally(at: [index])
       
    }
    
    func resetAllIcebergsAfterCollisionWithShip() {
        shuffleIcebergHorizontally(at: Array(icebergs.indices))
        shuffleIcebergVertically(at: Array(icebergs.indices))
    }
    
    func resetIcebergsToInitPosition() {
        for index in 0..<icebergs.count {
            icebergs[index].origin.x = icebergInitXOrigin[index]
            icebergs[index].origin.y = icebergInitYOrigin[index]
        }
         shuffleIcebergVertically(at: Array(icebergs.indices))
    }
    
    func isInHighscoreList(_ drivenSeaMiles: Double) -> Bool {
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

    func savePlayerInHighscoreList(userName: String, drivenSeaMiles: Double) {
        
        guard player != nil else {
            return
        }
        if player!.count == 10 {player!.removeLast()}
        let newPlayer = Player(name: userName, drivenMiles: drivenSeaMiles)
        player!.append(newPlayer)
        player!.sort(by: >)
        saveHighscorelistToDisc(player!)
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

    private func saveHighscorelistToDisc(_ player: [Player]) {
        fileHandler.savePlayerToFile(player: player, then: {result in
            if case .failure(let error) = result {
                print(error)
            }
        })
    }
    
    private func shuffleIcebergHorizontally(at indices: [Int]) {
        var xOrigin = icebergInitXOrigin
        indices.forEach({index in
            let randomIndex = Int.random(in: 0 ..< xOrigin.count)
            icebergs[index].origin.x = xOrigin.remove(at: randomIndex)
        })
    }
    
    private func shuffleIcebergVertically(at indices: [Int]) {
       var yOrigin = icebergInitYOrigin
        for index in 0..<icebergs.count {
            let randomIndex = Int.random(in: 0 ..< yOrigin.count)
            self.icebergs[index].origin.y = yOrigin.remove(at: randomIndex)
        }
    }
    
    private func calculateDistanceBetweenIcebergs() -> Double {
        if icebergs.count > 1 {
            return abs(icebergs[0].origin.y.distance(to: icebergs[1].origin.y))
        }
        return 0
    }
}
