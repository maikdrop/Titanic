/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

class TitanicGame {

    // MARK: - Properties
    private var icebergInitXOrigin = [Double]()
    private var icebergInitYOrigin = [Double]()
    private var distanceBetweenIcebergs = 0.0
    private(set) var icebergs = [Iceberg]()
    private let fileHandler = FileHandler()
    private var player: [Player]?
    private(set) var drivenSeaMiles = 0.0

    var drivenSeaMilesInHighscoreList: Bool {
           isInHighscoreList()
    }

    private var seaMilesPerSecond: Double {
        (Double(knots) / 60)/60
    }
    var knots: Int {
        startKnots - crashCount * knotsReducer
    }

    private(set) var crashCount = 0 {
        didSet {
            if crashCount == maxCrashs {
                 NotificationCenter.default.post(name: .GameDidEnd, object: self)
            }
        }
    }

    // MARK: - Creating a Titanic Game
    init(icebergs: [Iceberg]) {
        self.icebergs = icebergs
        self.icebergs.forEach({iceberg in
            icebergInitXOrigin.append(iceberg.origin.xCoordinate)
            icebergInitYOrigin.append(iceberg.origin.yCoordinate)
        })
        distanceBetweenIcebergs = calculateDistanceBetweenIcebergs()
    }

    deinit {
        print("DEINIT TitanicGame")
    }

    // MARK: - Public API
    /**
     Move icebergs vertically and calculate driven sea miles.
     */
    func moveIcebergsVertically() {
        drivenSeaMiles += seaMilesPerSecond
        drivenSeaMiles = drivenSeaMiles.round(to: 2)
        for index in 0..<icebergs.count {
            icebergs[index].center.yCoordinate += moveFactor - Double(crashCount)/2
        }
    }

    /**
     When iceberg reaches end of view the postion is reset behind the iceberg with smallest y Value.
     
     - Parameter index: index of iceberg in icebergs array
     */
    func endOfViewReachedFromIceberg(at index: Int) {
        assert(icebergs.indices.contains(index), "Titanic.endOfViewReachedFromIceberg(at: \(index)): chosen index not available in icebergs")
        if let icebergWithSmallestY = icebergs.min() {
            icebergs[index].origin.yCoordinate =
                icebergWithSmallestY.origin.yCoordinate - distanceBetweenIcebergs
        }
    }

    /**
     When a collision between ship and iceberg is detected crash count increases and alle icebergs were reset to a random position.
     */
    func collisionBetweenShipAndIceberg() {
        crashCount += 1
        shuffleIcebergs()
    }

    /**
     Resets scores and shuffles the position of all icebergs.
     
     - Important: should be called always before a new game is started
     */
    func startNewTitanicGame() {
        drivenSeaMiles = 0.0
        crashCount = 0
        shuffleIcebergs()
    }

    /**
     Saving Player into highscore list.
     
     - Parameter userName: name of user
     - Parameter completion: completion handler when player was saved
     */
    func savePlayer(userName: String, completion: (Error?) -> Void) {
        guard var newPlayerList = player else {
            return
        }
        if newPlayerList.count == maxPlayerCount { newPlayerList.removeLast()}
        let newPlayer = Player(name: userName, drivenMiles: drivenSeaMiles)
        newPlayerList.append(newPlayer)
        newPlayerList.sort(by: >)
        fileHandler.savePlayerToFile(player: newPlayerList) {result in
            if case .failure(let error) = result {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - Private methods
private extension TitanicGame {

    /**
     Calculates distance between two icebergs.
     
     - Returns: distance between two icebergs
     */
    private func calculateDistanceBetweenIcebergs() -> Double {
        if icebergs.count > 1 {
            return abs(icebergs[0].origin.yCoordinate.distance(to: icebergs[1].origin.yCoordinate))
        }
        return 0
    }

    /**
     Calls functions to shuffle iceberg coordinates vertically and horizontally.
     */
    private func shuffleIcebergs() {
        shuffleIcebergVertically(at: Array(icebergs.indices))
        shuffleIcebergHorizontally(at: Array(icebergs.indices))
    }

    /**
     Iceberg coordinates will be shuffled vertically.
     
     - Parameter indices: indices of icebergs which will be shuffled
     */
    private func shuffleIcebergVertically(at indices: [Int]) {
        var yOrigin = icebergInitYOrigin
        indices.forEach {index in
            let randomIndex = Int.random(in: 0 ..< yOrigin.count)
            self.icebergs[index].origin.yCoordinate = yOrigin.remove(at: randomIndex)
        }
    }

    /**
     Iceberg coordinates will be shuffled horizontally.
     
     - Parameter indices: indices of icebergs which will be shuffled
     */
    private func shuffleIcebergHorizontally(at indices: [Int]) {
        var xOrigin = icebergInitXOrigin
        indices.forEach {index in
            let randomIndex = Int.random(in: 0 ..< xOrigin.count)
            icebergs[index].origin.xCoordinate = xOrigin.remove(at: randomIndex)
        }
    }

    /**
     Calls file handler to get saved highscore list.
     
     - Returns: list with saved players
     */
    private func getHighscoreList() -> [Player]? {
        var playerList: [Player]?
        fileHandler.loadPlayerFile {result in
            if case .success(let player) = result {
                playerList = player
            } else {
                playerList = nil
            }
        }
        return playerList
    }

    /**
    Verification if driven sea miles are valid for a new highscore entry.
    
    - Returns: true when new highscore entry is possible
    */
    private func isInHighscoreList() -> Bool {
        player = getHighscoreList()
        guard player != nil else {
            return false
        }
        if player!.count < maxPlayerCount {
            return true
        } else if player!.count == maxPlayerCount, let drivenSeaMilesOfLastPlayer = player?.last?.drivenMiles {
            if drivenSeaMilesOfLastPlayer < drivenSeaMiles {
                return true
            }
        }
        return false
    }
}

// MARK: - Constants
extension TitanicGame {

    var countdownBeginningValue: Int {30}
    private var moveFactor: Double {10}
    private var maxCrashs: Int {5}
    private var startKnots: Int {50}
    private var knotsReducer: Int {5}
    private var maxPlayerCount: Int {10}
}
