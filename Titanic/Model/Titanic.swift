//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class Titanic {
    
    private var icebergInitOriginY = [Double]()
    private var icebergInitOriginX = [Double]()
    private var icebergSpacingAcrossYAxis = 0.0
    private(set) var icebergs = [Iceberg]()
    private(set) lazy var players: [Player] = {
        if let url = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
            .appendingPathComponent("highscore") {
            if let data = try? Data(contentsOf: url), let highscoreList = try? PropertyListDecoder().decode([Player].self, from: data) {
                return highscoreList
            }
        }
        return [Player]()
    }()
    
    init(icebergXOrigin: [Double], icebergSize: (width: Double, height: Double), shipHeight: Double) {
        self.icebergSpacingAcrossYAxis = icebergSize.height + 1.5 * shipHeight
        self.icebergInitOriginX = icebergXOrigin
        for index in 0..<icebergXOrigin.count{
            let yOrigin = Double(index) * self.icebergSpacingAcrossYAxis
            let origin = Point(x: icebergXOrigin[index], y: -yOrigin)
            let size = Size(width: icebergSize.width, height: icebergSize.height)
            let iceberg = Iceberg(origin: origin, size: size)
            icebergInitOriginY.append(iceberg.origin.y)
            icebergs += [iceberg]
        }
        shuffleLastIcebergAcrossXAxis()
        shuffleIcebergsAcrossYAxis()
    }
    
    func translateIcebergsAcrossYAxis(with factor: Double = 1) {
        for index in 0..<icebergs.count {
            icebergs[index].center.y += factor
        }
    }
    
    func loopingIcebergTranslation(at index: Int) {
      
        if let minimumIceberg = icebergs.min() {
              icebergs[index].origin.y = minimumIceberg.origin.y - self.icebergSpacingAcrossYAxis
        }
        shuffleIcebergAcrossXAxis(at: index)
    }
    
    func shipCollisionWithIceberg() {
        for index in 0..<icebergs.count {
            icebergs[index].origin.x = icebergInitOriginX[index]
        }
        shuffleIcebergsAcrossYAxis()
        shuffleLastIcebergAcrossXAxis()
    }
    
    private func shuffleLastIcebergAcrossXAxis() {
        let randomIndex = icebergs.index(icebergs.startIndex, offsetBy: (icebergs.count-1).arc4random)
        icebergs[icebergs.count-1].origin.x = icebergInitOriginX[randomIndex]
            
    }
    
    private func shuffleIcebergsAcrossYAxis() {
        var icebergOriginY = self.icebergInitOriginY
        for index in 0..<icebergs.count {
            let randomIndex = icebergOriginY.index(icebergOriginY.startIndex, offsetBy: icebergOriginY.count.arc4random)
            self.icebergs[index].origin.y = icebergOriginY.remove(at: randomIndex)
        }
    }
    
    private func shuffleIcebergAcrossXAxis(at index: Int) {
        let randomIndex = icebergInitOriginX.index(icebergInitOriginX.startIndex, offsetBy: (icebergInitOriginX.count-1).arc4random)
        self.icebergs[index].origin.x = icebergInitOriginX[randomIndex]
    }

    func savePlayerInHighscoreList(userName: String, drivenMiles: Double) {
        
        if players.count == 10 {players.removeLast()}
        let newPlayer = Player(name: userName, drivenMiles: drivenMiles)
        players.append(newPlayer)
        players.sort(by: >)
     
        if let url = try? FileManager.default.url(for: .applicationSupportDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
            .appendingPathComponent("highscore") {
            do  {
                try PropertyListEncoder().encode(players.self).write(to: url)
                print("saved successfully")
                
            } catch let error {
                print("couldn`t save \(error)")
            }
        }
    }
}
