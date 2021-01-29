/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import CoreData

class ScoreObject: NSManagedObject {

    /**
    Creates a database score object.
     
     - Parameter game: The game that the iceberg belongs to.
     - Parameter crashCount: The crash count of the ship with icebergs.
     - Parameter drivenSeaMiles: The driven sea miles during the game.
     - Parameter context: The context of the game.
     */
    static func createScore(for game: GameObject, crashCount: Int, drivenSeaMiles: Double, in context: NSManagedObjectContext) -> ScoreObject {

        let score = ScoreObject(context: context)
        score.game = game
        score.crashCount = Int32(crashCount)
        score.drivenSeaMiles = drivenSeaMiles
        return score
    }
}
