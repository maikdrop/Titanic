//
//  ShipView.swift
//  Titanic
//
//  Created by Maik on 13.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ShipView: UIView {
    
    var imageSize: CGSize {
        let ratio = GameView.ScreenSize.currentDevice.width / GameView.ScreenSize.iphoneSE.width
//        return CGSize(width: 50 * ratio, height: 117 * ratio)
        
        return CGSize(width: 45 * ratio, height: 105 * ratio)
    }
    
    override func draw(_ rect: CGRect) {
        if let shipImage = UIImage(named: "ship") {
            if let newImage = shipImage.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }
    
    deinit {
        print("DEINIT ShipView")
    }
}

extension UIFont {
    static func scalableFont(forTextStyle textStyle: TextStyle, fontSize: CGFloat) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle).withSize(fontSize)
        if #available(iOS 11.0, *) {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: preferredFont)
        } else {
            return UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    static func scalableWeightFont(forTextStyle textStyle: TextStyle, fontSize: CGFloat, weight: Weight) -> UIFont {
        let font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if #available(iOS 11.0, *) {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        } else {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
}
