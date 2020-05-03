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
    private(set) lazy var players = getPlayers()
    
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
    
    
    
    private func getPlayers() -> [Player]? {
        let defaults = UserDefaults.standard
        guard let highscoreList = defaults.object(forKey: "Highscorelist") as? Data else {
            print("No highscoreList found")
            return [Player]()
        }
        guard let playerHighscoreList = try? PropertyListDecoder().decode([Player].self, from: highscoreList) else {
            print("Error getHighscoreList() - Decode highscorelist")
            return nil
        }
        return playerHighscoreList
    }
    
    func savePlayer(userName: String, drivenMiles: Double) {
        if players != nil {
            if players!.count == 10 {players!.removeLast()}
            let newPlayer = Player(name: userName, drivenMiles: drivenMiles)
            players!.append(newPlayer)
            players!.sort(by: >)
            let defaults = UserDefaults.standard
            defaults.set(try? PropertyListEncoder().encode(players), forKey: "Highscorelist")
        }
    }
}
