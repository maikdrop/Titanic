//
//  IcebergView.swift
//  Titanic
//
//  Created by Maik on 19.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class IcebergView: UIView {
    
    var imageSize: CGSize {
        let ratio = GameView.ScreenSize.currentDevice.width / GameView.ScreenSize.iphoneSE.width
        return CGSize(width: 100 * ratio, height: 53 * ratio)
    }
    
    override func draw(_ rect: CGRect) {
        if let shipImage = UIImage(named: "iceberg") {
            if let newImage = shipImage.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }
    
    deinit {
        print("DEINIT IcebergView")
    }
}
