/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

extension TitanicGame {

    struct Score {

        // MARK: - Properties
        var drivenSeaMiles = 0.0
        var beginningKnots: Int
        var knots: Int {
            beginningKnots - crashCount * knotsReducer
        }
        var crashCount = 0
        var seaMilesPerSecond: Double {
            (Double(knots) / minutesPerHour) / secondsPerMinute
        }

        /**
         Increases driven sea miles.
         
         - Method should be called every time when the icebergs moved.
        */
        mutating func increaseDrivenSeaMiles() {
            drivenSeaMiles += seaMilesPerSecond
            drivenSeaMiles = drivenSeaMiles.round(to: 3)
        }
    }
}

// MARK: - Constants
extension TitanicGame.Score {

    private var minutesPerHour: Double { 60 }
    private var secondsPerMinute: Double { 60 }
    private var knotsReducer: Int { 15 }
}
