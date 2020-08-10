//
//  TitanicGame+Player.swift
//  Titanic
//
//  Created by Maik on 08.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension TitanicGame {

    struct Player: Codable {

        // MARK: - Properties
        private(set) var name: String
        private(set) var drivenMiles: Double
        private(set) var date: Date

        // MARK: - Create a Titanic Game Player
        init(name: String, drivenMiles: Double) {
            self.name = name
            self.drivenMiles = drivenMiles
            self.date = Date()
        }
    }
}

// MARK: - Implementation Comparable Protocol
extension TitanicGame.Player: Comparable {

    static func < (lhs: TitanicGame.Player, rhs: TitanicGame.Player) -> Bool {
        return (lhs.drivenMiles < rhs.drivenMiles)
    }

    static func == (lhs: TitanicGame.Player, rhs: TitanicGame.Player) -> Bool {
        return lhs.name == rhs.name && lhs.drivenMiles == rhs.drivenMiles
            && lhs.date == rhs.date
    }
}
