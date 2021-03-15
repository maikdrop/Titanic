/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI
import CoreData

struct GameListEntryView: View {

    // MARK: - Property wrappers
    @ObservedObject var game: GameObject

    // MARK: - Properties
    private let taskDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMMM yyyy HH:mm:ss"
        return formatter
    }()
}

// MARK: - View declaration
extension GameListEntryView {

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let date = game.stored {
                    Text(date, formatter: taskDateFormat)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                    Text(crashTxt + " " + milesTxt + " " + timerTxt)
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.callout)
                }
            }
            Spacer()
            Image(systemName: chevronImageName)
                .font(.body).foregroundColor(.gray)
        }
        .foregroundColor(Color(.label))
        .padding(paddingLength)
    }
}

// MARK: - Constants
private extension GameListEntryView {

    private var crashTxt: String {
        AppStrings.Game.crashesLblTxt + ": " + String(game.score?.crashCount ?? 0) + "," }
    private var milesTxt: String {
        AppStrings.Game.drivenSeaMilesLblTxt + ": " + String(game.score?.drivenSeaMiles ?? 0.0) + ","}
    private var timerTxt: String { "Timer: " + String(game.config?.timerCount ?? 0) }
    private var chevronImageName: String { "chevron.right" }
    private var paddingLength: CGFloat { 10 }
}
