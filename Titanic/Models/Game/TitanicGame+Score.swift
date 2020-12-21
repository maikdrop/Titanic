//
//  TitanicGame+Score.swift
//  Titanic
//
//  Created by Maik on 23.11.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension TitanicGame {

    struct Score {

        // MARK: - Properties
        var drivenSeaMiles = 0.0

        var knots: Int {
            startKnots - crashCount * knotsReducer
        }

        var crashCount = 0

        private var seaMilesPerSecond: Double {
            (Double(knots) / 60)/60
        }

        /**
         Increases driven sea miles by driven sea miles per second.
         
         - Method should be called every second to calculate the right distance.
        */
        mutating func increaseDrivenSeaMiles() {
            drivenSeaMiles += seaMilesPerSecond
            drivenSeaMiles = drivenSeaMiles.round(to: 2)
        }
    }
}

// Constants
extension TitanicGame.Score {

    private var knotsReducer: Int {5}
    private var startKnots: Int {50}
}
