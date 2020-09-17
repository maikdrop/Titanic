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
    private var icebergInitialXPos = [Double]()
    private var icebergInitialYPos = [Double]()
    private let fileHandler = FileHandler()

    private(set) var icebergs: [Iceberg]
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
        self.icebergs.forEach {iceberg in
            icebergInitialXPos.append(iceberg.origin.xCoordinate)
            icebergInitialYPos.append(iceberg.origin.yCoordinate)
        }
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
     When iceberg reaches end of view the iceberg is set to a new position.
     
     - Parameter index: index of iceberg in iceberg array
     */
    func endOfViewReachedFromIceberg(at index: Int) {

        assert(icebergs.indices.contains(index), "Titanic.endOfViewReachedFromIceberg(at: \(index)): chosen index not available in icebergs")

        icebergs[index].origin.yCoordinate = calculateNewYPosForIceberg(at: index) ?? -(icebergs[index].size.height)

        shuffleXPosOfIcebergs(at: [index])
    }

    /**
     When a collision between ship and iceberg is detected crash count increases and all icebergs were set to a random position.
     */
    func collisionBetweenShipAndIceberg() {
        crashCount += 1
        setStartPosOfIcebergs()
    }

    /**
     Resets scores and all icebergs were set to a random position.
     
     - Important: should be called always before a new game is started
     */
    func startNewTitanicGame() {
        drivenSeaMiles = 0.0
        crashCount = 0
        setStartPosOfIcebergs()
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
     Calculates vertical distance between two icebergs which follow each other.
     
     - Parameter index: index of iceberg
     - Returns: distance between two icebergs
     */
    private func calculateNewYPosForIceberg(at index: Int) -> Double? {

        if icebergs.count > 1 {
            if let icebergWithSmallestY = icebergs.min() {
                let indexFollower = index + 1
                if icebergs[optional:indexFollower] != nil {
                    return icebergWithSmallestY.origin.yCoordinate -
                        abs(icebergs[index].origin.yCoordinate.distance(to: icebergs[indexFollower].origin.yCoordinate))
                } else {
                    return icebergWithSmallestY.origin.yCoordinate -
                        abs(icebergs[index].origin.yCoordinate.distance(to: icebergs[0].origin.yCoordinate))
                }
            }
        }
        return nil
    }

    /**
     Set icebergs to a random start position.
     */
    private func setStartPosOfIcebergs() {
        shuffleXPosOfIcebergs(at: Array(icebergs.indices))
        setYPosOfIcebergs()
    }

    /**
     Set icebergs to initial y position.
     */
    private func setYPosOfIcebergs() {

        for index in 0..<icebergs.count {
            icebergs[index].origin.yCoordinate = icebergInitialYPos[index]
        }
    }

    /**
      Set icebergs to a random x position.
     
     - Parameter indices: indices of icebergs
     */
    private func shuffleXPosOfIcebergs(at indices: [Int]) {

        let uniqueXOriginShuffled = Array(
            repeating: icebergInitialXPos.uniqued().shuffled(),
            count: TitanicGame.rowsOfIcebergs)
        let xOriginShuffled = uniqueXOriginShuffled.reduce([]) { (result, element) in result + element}

        indices.forEach {index in
            icebergs[index].origin.xCoordinate = xOriginShuffled[index]
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

    static var rowsOfIcebergs: Int {2}
    static var icebergsInARow: Int {3}

    var countdownBeginningValue: Int {60}

    private var moveFactor: Double {10}
    private var maxCrashs: Int {5}
    private var startKnots: Int {50}
    private var knotsReducer: Int {5}
    private var maxPlayerCount: Int {10}
}
