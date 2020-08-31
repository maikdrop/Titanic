/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

final class ImageView: UIView {

     // MARK: - Properties
    var image: UIImage?
    var imageSize: CGSize {
        if image != nil, let width = UIApplication.shared.windows.first?.frame.width {
            let ratio =  width / referenceWidth
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
    private var referenceWidth: CGFloat {375}
}
