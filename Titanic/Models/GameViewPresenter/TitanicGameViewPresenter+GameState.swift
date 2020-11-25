/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

extension TitanicGameViewPresenter {

    enum GameState {
        case new
        case running
        case pause
        case resume
        case end
        case save
    }
}

extension TitanicGameViewPresenter.GameState: CaseIterable {

    // MARK: - Create a Game State
    init?(string: String) {
        switch string {
        case AppStrings.GameState.new: self = .new
        case AppStrings.GameState.pause: self = .pause
        case AppStrings.GameState.resume: self = .resume
        case AppStrings.GameState.save: self = .save
        default: return nil
        }
    }

    typealias State = TitanicGameViewPresenter.GameState

    // MARK: - Properties
    var stringValue: String {
        switch self {
        case .new: return AppStrings.GameState.new
        case .pause: return AppStrings.GameState.pause
        case .resume: return AppStrings.GameState.resume
        case .save: return AppStrings.GameState.save
        default: return ""
        }
    }

    var list: [TitanicGameViewPresenter.GameState] {
        switch self {
        case .running: return [.new, .pause, .save]
        case .pause: return [.resume, .save]
        case .end: return [.new]
        default: return []
        }
    }
}
