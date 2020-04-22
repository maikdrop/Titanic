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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let shipImage = UIImage(named: "ship") {
            if let newImage = shipImage.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }
}

extension UIImage {
    func resizeImage(for newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
