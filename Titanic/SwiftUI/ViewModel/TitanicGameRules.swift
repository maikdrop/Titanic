/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import SwiftUI
import Combine

class TitanicGameRules: ObservableObject {

    @Published private var rulesModel = GameRules(hideNextTime: false)

    private var autosaveCancellable: AnyCancellable?

    private(set) lazy var btnImgNames: [String] = getImageNames()
    var rules: [String] { rulesModel.rules }
    var btns: [String] { rulesModel.btns }
    var showAgainNextTime: Bool {
        get {
            rulesModel.hideNextTime
        }
        set {
            rulesModel.hideNextTime = newValue
        }
    }

    init() {
        autosaveCancellable = $rulesModel.sink { rules in
            UserDefaults.standard.set(rules.hideNextTime, forKey: AppStrings.UserDefaultKeys.rules)
        }
    }
}

// MARK: - Private utility methods
private extension TitanicGameRules {

    private func getImageNames() -> [String] {
        var names = [String]()
        btns.forEach { buttonTitle in
            switch buttonTitle {
            case AppStrings.HowToPlay.storedGamesBtn:
                names.append(AppStrings.ImageNames.storedGames)
            case AppStrings.HowToPlay.speedOptionBtn:
                names.append(AppStrings.ImageNames.speedometer)
            case AppStrings.HowToPlay.ctrlGameBtn:
                names.append(AppStrings.ImageNames.gameController)
            default:
                names.append("")
            }
        }
        return names
    }
}
