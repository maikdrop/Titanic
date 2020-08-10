/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

extension TitanicGame {

    struct Player: Codable {

        // MARK: - Properties
        private(set) var name: String
        private(set) var drivenMiles: Double
        private(set) var date: Date

        // MARK: - Create a Titanic Game Player
        init(name: String, drivenMiles: Double) {
            self.name = name
            self.drivenMiles = drivenMiles
            self.date = Date()
        }
    }
}

// MARK: - Implementation Comparable Protocol
extension TitanicGame.Player: Comparable {

    static func < (lhs: TitanicGame.Player, rhs: TitanicGame.Player) -> Bool {
        return (lhs.drivenMiles < rhs.drivenMiles)
    }

    static func == (lhs: TitanicGame.Player, rhs: TitanicGame.Player) -> Bool {
        return lhs.name == rhs.name && lhs.drivenMiles == rhs.drivenMiles
            && lhs.date == rhs.date
    }
}
