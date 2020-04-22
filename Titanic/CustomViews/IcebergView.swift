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
        return CGSize(width: 100 * ratio, height: 75 * ratio)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if let shipImage = UIImage(named: "iceberg") {
            if let newImage = shipImage.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }
}
