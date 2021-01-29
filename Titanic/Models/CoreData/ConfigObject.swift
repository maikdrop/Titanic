/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import CoreData

class ConfigObject: NSManagedObject {

    /**
    Creates a game configuration object for the database.
     
     - Parameter game: The game that the configuration belongs to.
     - Parameter timerCount: The game`s timer count.
     - Parameter speedFactor: The iceberg`s move factor.
     - Parameter sliderValue: The ships`s slider value.
     - Parameter context: The context of the game.
     */
    static func createConfig(for game: GameObject, timerCount: Int, moveFactor: Int, sliderValue: Float, in context: NSManagedObjectContext) -> ConfigObject {

        let config = ConfigObject(context: context)
        config.game = game
        config.timerCount = Int32(timerCount)
        config.moveFactor = Int32(moveFactor)
        config.sliderValue = sliderValue
        return config
    }
}
