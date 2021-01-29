/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

//source: https://stackoverflow.com/questions/56588332/align-two-swiftui-text-views-in-hstack-with-correct-alignment
//Answer: 3

import SwiftUI

struct HowToPlayView: View {

    @ObservedObject var titanicGameRules: TitanicGameRules
    @State private var width: CGFloat?

    // MARK: - Properties
    private var doneHandler: () -> Void

    // MARK: - Creates a game chooser view.
    init(titanicGameRules: TitanicGameRules, doneHandler: @escaping () -> Void) {
        self.titanicGameRules = titanicGameRules
        self.doneHandler = doneHandler
    }
}

// MARK: - View declaration
extension HowToPlayView {

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $titanicGameRules.showAgainNextTime) {
                        Text(AppStrings.HowToPlay.hideNxtTimeLblTxt)
                    }
                }
                Section(header: Text(AppStrings.Rules.goalSectionTitle)) {
                    Text(AppStrings.Rules.goalSectionContent)
                }
                Section(header: Text(AppStrings.HowToPlay.buttonSectionTitle)) {
                    ForEach(titanicGameRules.btns.indices, id: \.self) { index in
                        gameBtnDescriptions(for: index)
                    }
                }
                Section(header: Text(AppStrings.HowToPlay.rulesSectionTitle), footer:
                            Text(AppStrings.HowToPlay.rulesSectionFooter)) {
                    ForEach(titanicGameRules.rules.indices, id: \.self) { index in
                        ruleDescriptions(for: index)
                    }
                }
            }
            .font(Font.system(.body))
            .foregroundColor(Color(UIColor.label))
            .onPreferenceChange(WidthPreferenceKey.self) { widths in
                if let width = widths.max() {
                    self.width = width
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(AppStrings.HowToPlay.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: doneButton)
        }
    }
}

// MARK: - Private view elements
private extension HowToPlayView {

    private func gameBtnDescriptions(for index: Int) -> some View {
        Label {
            Text(titanicGameRules.btns[index])
        } icon: {
            Image(systemName: titanicGameRules.btnImgNames[index])
                .foregroundColor(Color(UIColor.oceanBlue))
        }
    }

    private func ruleDescriptions(for index: Int) -> some View {
        HStack {
            Text(String(index + 1) + ".")
                .equalWidth()
                .frame(width: width, alignment: .leading)
                .foregroundColor(Color(UIColor.oceanBlue))
                .font(Font.system(.largeTitle))
            Text(titanicGameRules.rules[index])
                .padding(edgeInsets)
        }
    }

    private var doneButton: some View {
        Button(action: doneHandler,
               label: {
                Text(AppStrings.ActionCommand.done)
                    .font(.body)
                    .fontWeight(.semibold)
               })
    }
}

// MARK: - Constants
extension HowToPlayView {

    private var edgeInsets: EdgeInsets {
        EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 0)
    }
}
