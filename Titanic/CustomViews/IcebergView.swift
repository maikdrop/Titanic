//
//  ImageView.swift
//  Titanic
//
//  Created by Maik on 19.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ImageView: UIView {

    var icebergImage: UIImage?
    var imageSize: CGSize {
        if icebergImage != nil, superview != nil {
            let ratio = superview!.frame.width / GameView.ScreenSize.iphoneSE.width
            return CGSize(width: icebergImage!.size.width * ratio, height: icebergImage!.size.height * ratio)
        }
        return CGSize.zero
    }

    override func draw(_ rect: CGRect) {
        if icebergImage != nil {
            if let newImage = icebergImage.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }

    deinit {
        print("DEINIT IcebergView")
    }
}
