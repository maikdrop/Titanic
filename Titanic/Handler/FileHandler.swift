/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

struct FileHandler {

    // MARK: - Properties
    private let url = try? FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true)
                        .appendingPathComponent("highscore.json")

    typealias Handler = (Result<[TitanicGame.Player], Error>) -> Void

    // MARK: - Public API for file loading and saving
    /**
    Loads and decodes json file with player as highscore list from Application Support Directory.
    
    - Parameter handler: handles success or failure of loading
    */
    func loadPlayerFile(then handler: Handler) {
        if let url = url {
            if !FileManager.default.fileExists(atPath: url.path) {
                handler(.success([TitanicGame.Player]()))
                return
            }
            if let data = try? Data(contentsOf: url) {
                do {
                    let player = try JSONDecoder().decode([TitanicGame.Player].self, from: data)
                    handler(.success(player))
                } catch {
                    handler(.failure(error))
                }
            }
        }
    }

    /**
    Encodes and saves json file with players as highscore list into Application Support Directory.
    
    - Parameter player: highscore list with top ten players
    - Parameter handler: handles success or failure of saving
    */
    func savePlayerToFile(player: [TitanicGame.Player], then handler: Handler) {
        if let url = url, let json = try? JSONEncoder().encode(player) {
            do {
                try json.write(to: url)
                 handler(.success(player))
            } catch {
                handler(.failure(error))
            }
        }
    }
}
