//
//  UIFont+Scale.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

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
