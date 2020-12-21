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

struct SlidableSlot: ViewModifier, Animatable {

    // MARK: - Property Wrapper
    @State private var currentSlotsWidth: CGFloat = 0 {
        didSet {
            if currentSlotsWidth == totalSlotWidth {
                localSlotState = true
                showingSlot = true
                resetSlot = !resetSlot
            }
        }
    }
    
    @State private var localSlotState: Bool = false
    @Binding private var editMode: EditMode
    @Binding private var showingSlot: Bool
    @Binding private var resetSlot: Bool
    
    // MARK: - Properties
    private var trailingSlot: Slot
    
    private var contentOffset: CGSize {
        .init(width: -self.currentSlotsWidth, height: 0)
    }
    
    private var slotOffset: CGSize {
        .init(width: self.totalSlotWidth - self.currentSlotsWidth, height: 0)
    }
    
    private func optWidth(value: CGFloat) -> CGFloat {
        min(abs(value), totalSlotWidth - 1)
    }
    
    private var totalSlotWidth: CGFloat {
        trailingSlot.style.slotWidth
    }
    
    var animatableData: Double {
        get { Double(self.currentSlotsWidth) }
        set { self.currentSlotsWidth = CGFloat(newValue) }
    }
    
    // MARK: - Creates a slidable modifier.
    public init(trailing: Slot, editMode: Binding<EditMode>, showingSlot: Binding<Bool>, resetSlot: Binding<Bool>) {
        _editMode = editMode
        trailingSlot = trailing
        _showingSlot = showingSlot
        _resetSlot = resetSlot
    }
}

// MARK: - View declarations
extension SlidableSlot {

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
                .offset(self.contentOffset)
                .onTapGesture() { handleTapGestures() }
                .onLongPressGesture() { handleTapGestures() }
                .disabled(!showingSlot)
            if editMode == .inactive {
                slotContainer
                    .offset(self.slotOffset)
                    .frame(width: self.totalSlotWidth)
            }
        }
        .gesture(swipeGesture)
        .onChange(of: editMode) {_ in flushState()}
        .onChange(of: resetSlot) { _ in
            if !localSlotState  {
                flushState()
            } else {
                localSlotState = false
            }
        }
    }
    
    @ViewBuilder
    private func displayedView(for slot: Slot) -> some View {
        Spacer()
        slot.image()
            .resizable()
            .scaledToFit()
            .foregroundColor(slot.style.imageColor)
            .frame(width: slot.style.slotWidth * imageWidthScaleFactor)
        Spacer()
    }
    
  
    private var slotContainer: some View {
        HStack {
            Spacer()
            VStack {
                displayedView(for: trailingSlot)
            }
            .frame(width: trailingSlot.style.slotWidth)
            .background(trailingSlot.style.background)
            .onTapGesture {
                if currentSlotsWidth == totalSlotWidth {
                    trailingSlot.action()
                }
            }
        }
    }
    
    // MARK: - Drag Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: dragMinDistance, coordinateSpace: .local)
            .onChanged { value in
                if editMode == .inactive {
                    if value.translation.width < 0 {
                        if currentSlotsWidth < totalSlotWidth {
                            withAnimation(.easeOut(duration: durationSwipingSlot)) {
                                currentSlotsWidth = totalSlotWidth
                            }
                        }
                    } else if currentSlotsWidth == totalSlotWidth {
                        withAnimation(.easeOut(duration: durationSwipingSlot)) {
                            self.currentSlotsWidth = 0
                        }
                    }
                }
            }
    }
}
 
// MARK: - Private methods
private extension SlidableSlot {
        
    /**
     Resets slot position with animation.
     */
    private func flushState() {
        withAnimation(.easeOut(duration: durationTapingSlot)) {
            currentSlotsWidth = 0
       }
    }
    
    /**
     Handles all tap gestures and resets slot states.
     */
    private func handleTapGestures() {
        localSlotState = false
        showingSlot = false
        resetSlot = !resetSlot
    }
}

// MARK: - Constants
private extension SlidableSlot {
    
    private var durationSwipingSlot: Double { 0.1 }
    private var durationTapingSlot: Double { 0.2 }
    private var imageWidthScaleFactor: CGFloat { 0.3 }
    private var dragMinDistance: CGFloat { 30 }
}
