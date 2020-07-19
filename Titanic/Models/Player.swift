//
//  Player.swift
//  Titanic
//
//  Created by Maik on 11.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct Player: Codable {
    
    private(set) var name: String
    private(set) var drivenMiles: Double
    private(set) var date: Date
    
    init(name: String, drivenMiles: Double){
        self.name = name
        self.drivenMiles = drivenMiles
        self.date = Date()
    }
}

extension Player: Comparable {
    
    static func < (lhs: Player, rhs: Player) -> Bool {
        return (lhs.drivenMiles < rhs.drivenMiles)
    }
}
