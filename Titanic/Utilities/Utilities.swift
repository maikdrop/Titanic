//
//  Utilities.swift
//  Titanic
//
//  Created by Maik on 04.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIColor {
    static let oceanBlue = UIColor.init(red: 0, green: 0.328521, blue: 0.574885, alpha: 1)
}

extension UIImage {
    func resizeImage(for newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
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

