//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class Titanic {
    
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
    
    init(numberOfIcebergs: Int, icebergOrigin: [(x: Double, y: Double)], icebergSize: [(width: Double, height: Double)]) {
        for index in 0..<numberOfIcebergs {
            let origin = Point(x: icebergOrigin[index].x, y: icebergOrigin[index].y)
            let size = Size(width: icebergSize[index].width, height: icebergSize[index].height)
            let iceberg = Iceberg(origin: origin, size: size)
            self.icebergs += [iceberg]
        }
    }
    
    func translateIcebergsAcrossYAxis(with factor: Double = 1) {
        for index in 0..<icebergs.count {
            icebergs[index].center.y += factor
        }
    }
    
    func resetIcebergAcrossYAxis(at index: Int) {
        icebergs[index].center.y = 0
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
