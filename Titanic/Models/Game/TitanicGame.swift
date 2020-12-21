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
    private(set) var score = Score() {
        didSet {
            if score.crashCount == maxCrashs {
                    NotificationCenter.default.post(name: .GameDidEnd, object: self)
            }
        }
    }
    private var player: [Player]?

    private var icebergInitialXPos = [Double]()
    private var icebergInitialYPos = [Double]()
    private var sliderValue: Float?
    private(set) var countdownBeginningValue = 60

    var drivenSeaMilesInHighscoreList: Bool {
           isInHighscoreList()
    }

    // MARK: - Create a Titanic game
    init<T: FileHandling>(icebergs: [Iceberg], dataHandler: T) where T.DataTyp == [Player] {
        self.icebergs = icebergs
        self.playerFetcher = dataHandler.fetchFromFile
        self.playerSaver = dataHandler.saveToFile
        self.icebergs.forEach { iceberg in
            icebergInitialXPos.append(iceberg.origin.xCoordinate)
            icebergInitialYPos.append(iceberg.origin.yCoordinate)
        }
    }

    convenience init<T: FileHandling>(icebergs: [Iceberg], date: Date, dataHandler: T) where T.DataTyp == [Player] {
        self.init(icebergs: icebergs, dataHandler: dataHandler)
        fetchGame(matching: date)
    }

    deinit {
        print("DEINIT TitanicGame")
    }

    // MARK: - Public API
    /**
     Moves all icebergs vertically and calculates the driven sea miles.
     */
    func moveIcebergsVertically() {
        score.increaseDrivenSeaMiles()
        for index in 0..<icebergs.count {
            icebergs[index].center.yCoordinate += moveFactor - Double(score.crashCount)/2
        }
    }

    /**
     When an iceberg reaches the end of the view, the iceberg is moved to a new position.
     
     - Parameter index: index of iceberg
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
     Resets scores and all icebergs were set to a random position.
     
     - Important: should be called always before a new game is started
     */
    func startNewTitanicGame() {
        score.crashCount = 0
        score.drivenSeaMiles = 0.0
        setStartPosOfIcebergs()
    }

    /**
     Get a random value for a slider within two values. If a stored game was fetched, you get the stored slider value.
     
     - Parameter min: minimum value
     - Parameter max: maximum value
     
     - Returns: a slider value
     */
    func getSliderValue(within min: Float, and max: Float) -> Float {
        sliderValue ?? Float.random(in: min...max)
    }

    /**
     Saves a player with the given name into the highscore list.
     
     - Parameter userName: name of user
     - Parameter completion: completion handler is called when players were saved
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
    }

    /**
     Fetches game and setups new game from fetched data.
     
     - Parameter date: date of saved game that is being searched for
     */
    private func fetchGame(matching date: Date) {
        GameHandling().fetchFromDatabase(matching: date) { result in
            if case .success(let game) = result {
                if let fetchedGame = game {

//                    print("FETCH GAME START")
//                    print("Fetched Slider Value")
//                    print(fetchedGame.sliderValue)
//                    print("Fetched Timer Count")
//                    print(fetchedGame.timerCount)

                    sliderValue = fetchedGame.sliderValue
                    countdownBeginningValue = Int(fetchedGame.timerCount)

                    if let fetchedIcebergs = fetchedGame.icebergs?.allObjects as? [IcebergObject] {
//                        print("Fetched Icebergs")
                        for iceberg in fetchedIcebergs {
//                            print("Center X")
                            print(iceberg.centerX)
//                            print("Center Y")
                            print(iceberg.centerY)

                        }
                        setStartPosOfIcebergs(from: fetchedIcebergs)
                    }

                    if let fetchedScore = fetchedGame.score {
                        score.crashCount = Int(fetchedScore.crashCount)
                        score.drivenSeaMiles = fetchedScore.drivenSeaMiles
//                        print("Fetched Crash Count")
//                        print(score.crashCount)
//                        print("Fetched Driven Sea Miles")
//                        print(score.drivenSeaMiles)
                    }
//                    print("FETCHED GAME END")
                }
            }
        }
    }

    /**
     Saves game and calls back if saving was successful or not.
     
     - Parameter sliderValue: slider value
     - Parameter currentCountdown: current countdown timer count
     - Parameter completion: completion handler calls back when saving the game was successful or not
     */
    func saveGame(sliderValue: Float, countdownCount: Int, completion: (Error?) -> Void) {

        GameHandling().updateDatabase(icebergs: icebergs,
                                      score: score,
                                      sliderValue: sliderValue,
                                      currentCountdown: countdownCount) { result in

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
     Calculates the vertical distance between two icebergs, which follow each other.
     
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
     Set all icebergs to a start position from fetched Icebergs.
     
     - Parameter fetchedIcebergs: fetched icebergs
     */
    private func setStartPosOfIcebergs(from fetchedIcebergs: [IcebergObject]) {

        if fetchedIcebergs.count == self.icebergs.count {

            for index in 0..<self.icebergs.count {

                self.icebergs[index].center.xCoordinate = fetchedIcebergs[index].centerX
                self.icebergs[index].center.yCoordinate = fetchedIcebergs[index].centerY
            }
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
     Set all icebergs to initial y position.
     */
    private func setYPosOfIcebergs() {

        for index in 0..<icebergs.count {
            icebergs[index].origin.yCoordinate = icebergInitialYPos[index]
        }
    }

    /**
      Set all icebergs to a random x position.
     
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

    static var rowsOfIcebergs: Int {2}
    static var icebergsInARow: Int {3}
    private var moveFactor: Double {10}
    private var maxPlayerCount: Int {10}
    private var maxCrashs: Int {5}
}
