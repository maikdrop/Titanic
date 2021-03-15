/*
MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

extension UIFont {
    
    /**
    Scales the font for a text style.
    
    - Parameter textStyle: The text style to scale.
    - Parameter fontSize: The font size to scale.
     
    - Returns: scaled and styled font
    */
    func scalableFont(forTextStyle textStyle: TextStyle, fontSize: CGFloat) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle).withSize(fontSize)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: preferredFont)
    }

    /**
    Scales font weight for a text style.
    
    - Parameter textStyle: The text style to scale.
    - Parameter fontSize: The font size to scale.
    - Parameter weight: The weight to scale.
     
    - Returns: scaled and styled font
    */
    func scalableFontWeight(forTextStyle textStyle: TextStyle, fontSize: CGFloat, weight: Weight) -> UIFont {
        let preferredFont = UIFont.preferredFont(forTextStyle: textStyle).withSize(fontSize)
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: preferredFont)
    }
}
