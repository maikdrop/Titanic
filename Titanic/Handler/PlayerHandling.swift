/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

struct PlayerHandling: FileHandling {

    // MARK: - Properties
    private var url = try? FileManager.default.url(
                        for: .applicationSupportDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true)

    typealias DataTyp = [TitanicGame.Player]

    typealias Handler = (Result<DataTyp, Error>) -> Void

    init(fileName: String) {
        self.url = url?.appendingPathComponent(fileName)
    }

    /**
     Fetches all saved players from JSON file.
     
     - Parameter completion: completion handler is called when players were fetched
     */
    func fetchFromFile(then completion: (Handler)) {

        var data: Data?

        if let url = url {
            if !FileManager.default.fileExists(atPath: url.path) {
                completion(.success(DataTyp()))
                return
            }

            do {
                data = try Data(contentsOf: url)
            } catch {
                completion(.failure(DataHandlingError.readingError(
                                        message: AppStrings.ErrorAlert.fileReadingErrorMessage)))
            }
            do {
                let player = try JSONDecoder().decode(DataTyp.self, from: data!)
                completion(.success(player))
            } catch {
                completion(.failure(DataHandlingError.decodingError(
                                        message: AppStrings.ErrorAlert.jsonDecodingErrorMessage)))
            }
        }
    }

    /**
     Saves players in a JSON file.
     
     - Parameter player: players to save
     - Parameter completion: completion handler calls back when players were saved
     */
    func saveToFile(data: DataTyp, then completion: (Handler)) {

        var json: Data?

        if let url = url {
            do {
                json = try JSONEncoder().encode(data)
            } catch {
                completion(.failure(DataHandlingError.encodingError(
                                        message: AppStrings.ErrorAlert.jsonEncodingErrorMessage)))
            }
            do {
                try json?.write(to: url)
                completion(.success(data))
            } catch {
                completion(.failure(DataHandlingError.writingError(
                                        message: AppStrings.ErrorAlert.fileWritingErrorMessage)))
            }
        }
    }
}
