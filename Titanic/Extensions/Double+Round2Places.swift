//
//  Double+Round2Places.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
