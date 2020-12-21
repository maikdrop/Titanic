/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI
import CoreData

struct GameChooserView: View {

    // MARK: - Property wrappers
    @Environment(\.managedObjectContext) var context
    @ObservedObject var gamePicker: GamePickerDelegate
    @State private var editMode: EditMode = .inactive

    // MARK: - Properties
    private var cancelHandler: () -> Void

    // MARK: - Creates a game chooser view.
    init(gamePicker: GamePickerDelegate, cancelHandler: @escaping () -> Void) {
        self.gamePicker = gamePicker
        self.cancelHandler = cancelHandler
    }
}

// MARK: - View declaration
extension GameChooserView {

    var body: some View {
        NavigationView {
            GameListView(gamePicker: gamePicker, editMode: $editMode, cancelHandler: cancelHandler)
                .navigationBarTitle(AppStrings.Storage.title)
                .environment(\.editMode, $editMode)
        }
    }
}
