/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

extension GameViewPresenter {

    enum GameStatus {
        case new
        case running
        case pause
        case resume
        case end
    }
}

extension GameViewPresenter.GameStatus {

    // MARK: - Create a Game Status
    init?(string: String) {
        switch string {
        case AppStrings.GameStatus.new: self = .new
        case AppStrings.GameStatus.pause: self = .pause
        case AppStrings.GameStatus.resume: self = .resume
        default: return nil
        }
    }

    typealias Status = GameViewPresenter.GameStatus

    // MARK: - Properties
    static var all: [Status] {
        [GameViewPresenter.GameStatus.new, .running, .pause, .resume, .end]
    }

    var stringValue: String {
        switch self {
        case .new: return AppStrings.GameStatus.new
        case .pause: return AppStrings.GameStatus.pause
        case .resume: return AppStrings.GameStatus.resume
        default: return ""
        }
    }

    var list: [GameViewPresenter.GameStatus] {
        switch self {
        case .running: return [.new, .pause]
        case .pause: return [.resume]
        case .end: return [.new]
        default: return []
        }
    }
}
