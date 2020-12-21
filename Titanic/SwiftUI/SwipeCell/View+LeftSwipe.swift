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

extension View {
    
    /**
     Creates a view modifier for a left swipe.
     
     - Parameter delete: slot type
     - Parameter editMode: a binding to the edit mode of the list
     - Parameter showingSlot: a binding to the visual state of the slot
     - Parameter resetSlot: a binding in order to reset all displayed slots
     
     - Returns: a slidable view modfier to delete items from a list
     */
    func onLeftSwipe(delete: Slot, editMode: Binding<EditMode>, showingSlot: Binding<Bool>, resetSlot: Binding<Bool>) -> some View {
        self.modifier(SlidableSlot(trailing: delete, editMode: editMode, showingSlot: showingSlot, resetSlot: resetSlot))
    }
}
