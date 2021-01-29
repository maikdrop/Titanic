/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI
import CoreData

struct GameListView: View {

    // MARK: - Property wrappers
    @Environment(\.managedObjectContext) var context
    @FetchRequest private var games: FetchedResults<GameObject>
    @ObservedObject private var gamePicker: GamePickerDelegate

    @State private var activeAlert: ActiveAlert = .deleteSingleGame
    @State private var indexToDelete: Int?
    @State private var selectedRows = Set<Int>()
    @State private var showingAlert = false
    @State private var showingSlot = false
    @State private var resetSlot = false
    @Binding private var editMode: EditMode

    // MARK: Properties
    private var cancelHandler: () -> Void

    // MARK: - Creates a game list and fetches game data from the database.
    init(gamePicker: GamePickerDelegate, editMode: Binding<EditMode>, cancelHandler: @escaping () -> Void) {
        self.gamePicker = gamePicker
        _editMode = editMode
        self.cancelHandler = cancelHandler
        let request = GameObject.fetchGamesRequest(predicate: nil)
        _games = FetchRequest(fetchRequest: request)
    }
}

// MARK: - View declaration
extension GameListView {

    var body: some View {
        List(selection: $selectedRows) {
            forEachGame
        }
        .navigationBarItems(leading: deleteBtn, trailing: editBtn)
        .listStyle(InsetGroupedListStyle())
        .alert(isPresented: $showingAlert) {
            switch activeAlert {
            case .deleteSingleGame: return singleDeletionAlert
            case .deleteMultipleGames: return multipleDeletionAlert
            case .error: return errorAlert
            }
        }
    }
}

// MARK: - View elements
extension GameListView {

    private var forEachGame: some View {
        ForEach(games.indices, id: \.self) { index in
            Button(action: {
                self.gamePicker.storedGameDate = games[index].stored
            }, label: {
                gameListEntry(for: index)
            })
            .deleteDisabled(!editMode.isEditing)
        }
        .onDelete(perform: {_ in })
        .listRowInsets(EdgeInsets()).clipped()
    }

    private func gameListEntry(for index: Int) -> some View {
        GameListEntryView(game: games[index]).onLeftSwipe(
            delete: createDeleteSlot(for: index),
            editMode: $editMode,
            showingSlot: $showingSlot,
            resetSlot: $resetSlot)
    }

    // MARK: - Buttons
    private var editBtn: some View {
        if editMode == .inactive {
            return Button(action: { editBtnAction() }, label: {
                VStack(alignment: .trailing) {
                    Text(AppStrings.ActionCommand.edit)
                        .font(.body)
                        .fontWeight(.regular)
                }
            })
            .disabled(games.isEmpty)
        } else {
            return Button(action: { withAnimation(.linear) { editMode = .inactive }}, label: {
                VStack(alignment: .trailing) {
                    Text(AppStrings.ActionCommand.done)
                        .font(.body)
                        .fontWeight(.semibold)
                }
            })
            .disabled(games.isEmpty)
        }
    }

    private var deleteBtn: some View {
        if editMode == .inactive {
            return Button(AppStrings.ActionCommand.cancel,
                          action: cancelHandler)
                .font(.body)
                .disabled(false)
        } else {
            return Button(AppStrings.ActionCommand.delete,
                          action: deleteBtnAction)
                .font(.body)
                .disabled(selectedRows.isEmpty)
        }
    }

    private var cancelBtn: some View {
        Button(AppStrings.ActionCommand.cancel, action: cancelHandler)
            .font(.body)
    }

    // MARK: - Alerts
    private var errorAlert: Alert {
        Alert(title: Text(AppStrings.ErrorAlert.title),
              message: Text(AppStrings.ErrorAlert.databaseDeletingErrorMessage),
              dismissButton: .default(Text(AppStrings.ActionCommand.okay)) {
                cleaningUpUI()
                activeAlert = .deleteSingleGame
              })
    }

    private var multipleDeletionAlert: Alert {
        Alert(title: Text(AppStrings.DeletionAction.title),
              message: Text(createMessageTextMultipleDeletion()),
              primaryButton: .destructive(Text(AppStrings.ActionCommand.delete)) {
                deleteMultipleGamesFromAlert()
              }, secondaryButton: .cancel(Text(AppStrings.ActionCommand.cancel)))
    }

    private var singleDeletionAlert: Alert {
        Alert(title: Text(AppStrings.DeletionAction.title),
              message: Text(AppStrings.DeletionAction.messageSingle),
              primaryButton: .destructive(Text(AppStrings.ActionCommand.delete)) {
                cleaningUpUI()
                deleteSingleGameFromAlert()
              }, secondaryButton: .cancel(Text(AppStrings.ActionCommand.cancel)) {
                cleaningUpUI()
              })
    }
}

// MARK: - Private user intents
private extension GameListView {

    // MARK: - Slot action
    /**
     Prepares an alert in order to delete a single game.
     
     - Parameter index: The index of a row in the list.
     */
    private func deleteSlotAction(for index: Int) {
        activeAlert = .deleteSingleGame
        indexToDelete = index
        showingAlert = true
    }

    // MARK: - Button actions
    /**
     Changes the edit mode of the list.
     */
    private func editBtnAction() {
        resetSlot = !resetSlot
        if showingSlot {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + animationDelay,
                execute: { withAnimation(.linear) { editMode = .active }})
        } else {
            withAnimation(.linear) { editMode = .active }
        }
        selectedRows = Set<Int>()
    }

    /**
     Prepares an alert in order to delete multiple games.
     */
    private func deleteBtnAction() {
        activeAlert = .deleteMultipleGames
        showingAlert = true
    }

    // MARK: - Alert button actions
    /**
    Animates the deletion of a single game.
     */
    private func deleteSingleGameFromAlert() {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + animationDelay,
            execute: { withAnimation(.spring()) {
                if let index = indexToDelete {
                    deleteGame(at: Set([index]))
                }
            }
        })
    }

    /**
    Animates the deletion of multiple games
     */
    private func deleteMultipleGamesFromAlert() {
        withAnimation(.linear) { editMode = .inactive }
        DispatchQueue.main.async {
            deleteGame(at: selectedRows)
            selectedRows = Set<Int>()
        }
    }
}

// MARK: - Private database access methods
private extension GameListView {

    /**
     Deletes a game from the database.
     
     - Parameter indexSet: A set of game indices that will be deleted.
     */
    private func deleteGame(at index: Set<Int>) {
        var gamesArray = [GameObject]()

        index.forEach { gamesArray.append(games[$0]) }

        GameHandling().delete(games: gamesArray) { result in
            if case .failure = result {
                DispatchQueue.main.async {
                    activeAlert = .error
                    showingAlert = true
                }
            }
        }
    }
}

// MARK: - Private utility methods
private extension GameListView {

    /**
    Creates a slot in order to delete an item from a row.
     
     - Parameter index: The index of a row in the list.
     */
    private func createDeleteSlot(for index: Int) -> Slot {
        Slot(image: { Image(systemName: trashImageName) },
             action: { deleteSlotAction(for: index) },
             style: .init(background: .red, slotWidth: slotWidth))
    }

    /**
    Creates the alert message in order to delete multiple games.
     */
    private func createMessageTextMultipleDeletion() -> String {

        if selectedRows.count > 1 {
            return insertNumber(in: AppStrings.DeletionAction.messageMultiple)
        } else {
            return AppStrings.DeletionAction.messageSingle
        }
    }

    /**
     Inserts the number of games to delete.
     
     - Parameter string: The text where the number will be inserted.
     
     - Returns: A text with the inserted number.
     */
    private func insertNumber(in text: String) -> String {
        let numberToEraseAsString = String(selectedRows.count)
        return text.replacingOccurrences(of: AppStrings.DeletionAction.number, with: numberToEraseAsString)
    }

    /**
    Changes the edit mode and resets the displayd slot in the list.
     */
    private func cleaningUpUI() {
        editMode = .inactive
        resetSlot = !resetSlot
    }
}

// MARK: - Constants
extension GameListView {

    private var animationDelay: Double { 0.2 }
    private var trashImageName: String { "trash.fill" }
    private var slotWidth: CGFloat { 80 }
}
