//
//  UtilitieExtensions.swift
//  Titanic
//
//  Created by Maik on 04.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

//MARK: - Utility Extensions
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

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return self.filter {seen.insert($0).inserted}
    }
}

extension UIFont {
    func scalableFont(forTextStyle textStyle: TextStyle, fontSize: CGFloat) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle).withSize(fontSize)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: preferredFont)
    }
    
    func scalableWeightFont(forTextStyle textStyle: TextStyle, fontSize: CGFloat, weight: Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
    }
}
