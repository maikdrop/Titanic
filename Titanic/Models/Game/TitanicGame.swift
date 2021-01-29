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
    private let playerFetcher: ((Result<[Player], Error>) -> Void) -> Void
    private let playerSaver: ([Player], (Result<[Player], Error>) -> Void) -> Void

    private(set) var icebergs: [Iceberg]
    private(set) var score = Score(beginningKnots: TitanicGame.SpeedOption.medium.knots) {
        didSet {
            if score.crashCount == maxCrashs {
                NotificationCenter.default.post(name: .GameDidEnd, object: self)
            }
        }
    }

    private var player: [Player]?
    private var icebergInitialXPos = [Double]()
    private var icebergInitialYPos = [Double]()

    var drivenSeaMilesInHighscoreList: Bool {
           isInHighscoreList()
    }

    // MARK: - Create a Titanic game
    init<T: FileHandling>(initialIcebergs: [Iceberg], score: Score, dataHandler: T) where T.DataTyp == [Player] {
        self.icebergs = initialIcebergs
        self.score = score
        playerFetcher = dataHandler.fetchFromFile
        playerSaver = dataHandler.saveToFile
        self.icebergs.forEach { iceberg in
            icebergInitialXPos.append(iceberg.origin.xCoordinate)
            icebergInitialYPos.append(iceberg.origin.yCoordinate)
        }
        setStartPosOfIcebergs()
    }

    convenience init<T: FileHandling>(initialIcebergs: [Iceberg], score: Score, dataHandler: T, fetchedCenterPos: [Iceberg.Point]) where T.DataTyp == [Player] {
        self.init(initialIcebergs: initialIcebergs, score: score, dataHandler: dataHandler)
        setStartPosOfIcebergs(from: fetchedCenterPos)
    }

    deinit {
        print("DEINIT TitanicGame")
    }
}

// MARK: - Public API
extension TitanicGame {

    /**
     Moves all icebergs vertically and calculates the driven sea miles.
     
     - Parameter speedFactor: The factor how far the icebergs will be moved.
     */
    func moveIcebergsVertically(with speed: Int = SpeedOption.medium.rawValue) {
        let moveFactor = Double(speed) - Double(score.crashCount)/2
        for index in 0..<icebergs.count {
            icebergs[index].center.yCoordinate += moveFactor
        }
        score.increaseDrivenSeaMiles()
    }

    /**
     When an iceberg reaches the end of the view, the iceberg is moved to a new position.
     
     - Parameter index: The index of the iceberg in the array.
     */
    func endOfViewReachedFromIceberg(at index: Int) {

        assert(icebergs.indices.contains(index), "Titanic.endOfViewReachedFromIceberg(at: \(index)): chosen index not available in icebergs")

        icebergs[index].origin.yCoordinate = calculateNewYPosForIceberg(at: index) ?? -(icebergs[index].size.height)

        shuffleXPosOfIcebergs(at: [index])
    }

    /**
     When a collision between ship and iceberg is detected, the crash count increases and all icebergs were set to a random position.
     */
    func collisionBetweenShipAndIceberg() {
        score.crashCount += 1
        setStartPosOfIcebergs()
    }

    /**
     Saves a player with the given name into the highscore list.
     
     - Parameter userName: The user`s name.
     - Parameter completion: The completion handler that calls back when saving the player was successful or not.
     */
    func savePlayer(userName: String, completion: (Error?) -> Void) {
        guard var newPlayerList = player else {
            return
        }
        if newPlayerList.count == maxPlayerCount { newPlayerList.removeLast()}
        let newPlayer = Player(name: userName, drivenMiles: score.drivenSeaMiles)
        newPlayerList.append(newPlayer)
        newPlayerList.sort(by: >)
        playerSaver(newPlayerList) { result in
            if case .failure(let error) = result {
                completion(error)
            } else {
                completion(nil)
            }
        }
        score.drivenSeaMiles = 0.0
    }
}

// MARK: - Private methods
private extension TitanicGame {

    /**
     Calculates the vertical distance between two icebergs, which follow each other.
     
     - Parameter index: The index of the iceberg in the array.
     
     - Returns: The distance between the coordinates of two icebergs.
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
     Set all icebergs to a start position that based on the coordinates of the fetched Icebergs.
     
     - Parameter fetchedIcebergs: The fetched icebergs from the data base.
     */
    private func setStartPosOfIcebergs(from fetchedCenterPos: [Iceberg.Point]) {

        if fetchedCenterPos.count == icebergs.count {
            for index in 0..<icebergs.count {
                icebergs[index].center.xCoordinate = fetchedCenterPos[index].xCoordinate
                icebergs[index].center.yCoordinate = fetchedCenterPos[index].yCoordinate
            }
            icebergs.sort(by: { $0.center.yCoordinate > $1.center.yCoordinate })
        }
    }

    /**
     Set all icebergs to a random start position.
     */
    private func setStartPosOfIcebergs() {
        shuffleXPosOfIcebergs(at: Array(icebergs.indices))
        setYPosOfIcebergs()
    }

    /**
     Set all icebergs to the initial y position.
     */
    private func setYPosOfIcebergs() {

        for index in 0..<icebergs.count {
            icebergs[index].origin.yCoordinate = icebergInitialYPos[index]
        }
    }

    /**
      Set all icebergs to a random x position.
     
     - Parameter indices: The indices of the icebergs in the array.
     */
    private func shuffleXPosOfIcebergs(at indices: [Int]) {

        let uniqueXOriginShuffled = Array(
            repeating: icebergInitialXPos.uniqued().shuffled(),
            count: TitanicGame.rowsOfIcebergs)
        let xOriginShuffled = uniqueXOriginShuffled.reduce([]) { (result, element) in result + element}

        indices.forEach { index in
            icebergs[index].origin.xCoordinate = xOriginShuffled[index]
        }
    }

    /**
     Fetches all players from the saved highscore list.
     
     -  Returns: players of the highscore list
     */
    private func getHighscoreList() -> [Player]? {
        var playerList: [Player]?
        playerFetcher { result in
            if case .success(let player) = result {
                playerList = player
            } else {
                playerList = nil
            }
        }
        return playerList
    }

    /**
    Verifies the driven sea miles for a new highscore entry.
    
    - Returns: true when a new highscore entry is possible
    */
    private func isInHighscoreList() -> Bool {
        player = getHighscoreList()
        guard player != nil else {
            return false
        }
        if player!.count < maxPlayerCount {
            return true
        } else if player!.count == maxPlayerCount, let drivenSeaMilesOfLastPlayer = player?.last?.drivenMiles {
            if drivenSeaMilesOfLastPlayer < score.drivenSeaMiles {
                return true
            }
        }
        return false
    }
}

// MARK: - Constants
extension TitanicGame {

    static var rowsOfIcebergs: Int { 2 }
    static var icebergsInARow: Int { 3 }
    private var maxPlayerCount: Int { 10 }
    private var maxCrashs: Int { 5 }
}
