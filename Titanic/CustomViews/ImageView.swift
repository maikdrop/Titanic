//
//  IcebergView.swift
//  Titanic
//
//  Created by Maik on 19.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ImageView: UIView {
    
     // MARK: - Properties
    var image: UIImage?
    var imageSize: CGSize {
        if image != nil, superview != nil {
            let ratio = superview!.bounds.width / referenceWidth
            return CGSize(width: image!.size.width * ratio, height: image!.size.height * ratio)
        }
        return CGSize.zero
    }
    
    deinit {
        print("DEINIT ImageView")
    }
}

// MARK: - Default Methods
extension ImageView {
    
    override func draw(_ rect: CGRect) {
        if image != nil {
            if let newImage = image!.resizeImage(for: imageSize) {
                newImage.draw(in: bounds)
            }
        }
    }
}

// MARK: - Constants
extension ImageView {
    private var referenceWidth: CGFloat {320}
}
