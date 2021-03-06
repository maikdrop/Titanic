/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//Source: https://github.com/EnesKaraosman/SwipeCell
//Customized for project purpose

import SwiftUI

// swiftlint:disable identifier_name
struct Slot: Identifiable {

    // MARK: - Properties
    let id = UUID()
    let image: () -> Image
    let action: () -> Void
    let style: SlotStyle

    // MARK: - Creates a Slot.
    init(image : @escaping () -> Image, action: @escaping () -> Void, style: SlotStyle) {
        self.image = image
        self.action = action
        self.style = style
    }
}

struct SlotStyle {

    // MARK: - Properties
    let background: Color
    let imageColor: Color
    let slotWidth: CGFloat

    // MARK: - Creates a slot style.
    init(background: Color, imageColor: Color = .white, slotWidth: CGFloat = 60) {
        self.background = background
        self.imageColor = imageColor
        self.slotWidth = slotWidth
    }
}
