//
//  UIImage+Resize.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

extension UIImage {
    func resizeImage(for newSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { (_) in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
