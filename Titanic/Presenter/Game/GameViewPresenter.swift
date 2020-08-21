/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import Combine
import UIKit

class GameViewPresenter {

    // MARK: - Properties
    private var game: TitanicGame! {
        didSet {
             setupSubscriberForGameEnd()
        }
    }
    private var cancellableObserver: Cancellable?
    private lazy var icebergImage = UIImage(named: icebergImageName)
    private weak var gameViewDelegate: GameViewDelegate?

    private(set) var gameState: GameState? {
        didSet {
            switch gameState {
            case .new:
                game.startNewTitanicGame()
                gameViewDelegate?.gameDidStart()
                gameState = .running
            case .pause:
                gameViewDelegate?.gameDidPause()
            case .resume:
                gameViewDelegate?.gameDidResume()
                gameState = .running
            case .end:
                gameViewDelegate?.gameDidUpdate()
                game.drivenSeaMilesInHighscoreList == true ?
                    gameViewDelegate?.gameEndedWithHighscore() : gameViewDelegate?.gameEndedWithoutHighscore()
            default:
                break
            }
        }
    }

    // MARK: - Objects for GameView
    private lazy var icebergs = setUpIcebergs()

    private(set) lazy var ship: ImageView =  {
        let shipView = ImageView()
        if let shipImage = UIImage(named: shipImageName) {
            shipView.image = shipImage
            shipView.backgroundColor = .clear
        }
        return shipView
    }()

    // MARK: - Access to the Model
    var icebergsToDisplay: [CGPoint] {
        var center = [CGPoint]()
        game.icebergs.forEach {iceberg in
            center.append(CGPoint(x: iceberg.center.xCoordinate, y: iceberg.center.yCoordinate))
        }
        return center
    }
    var knots: Int {
        gameState == .running ? game.knots : 0
    }
    var drivenSeaMiles: Double {
        game.drivenSeaMiles
    }
    var crashCount: Int {
        game.crashCount
    }
    var countdownBeginningValue: Int {
        game.countdownBeginningValue
    }

    // MARK: - Create a GameView Presenter and game object
    init() {
        game = createGameModel(from: icebergs)
    }

    deinit {
        cancellableObserver?.cancel()
        print("DEINIT GameViewPresenter")
    }
}

// MARK: - Public API: Intents
extension GameViewPresenter {

    func changeGameState(to newState: String) {
        gameState = GameState(string: newState)
    }

    /**
     While game is running iceberg is moving vertically.
     */
    func moveIcebergsVertically() {
        if gameState == .running {
            game?.moveIcebergsVertically()
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running it will be detected that an iceberg reached the end of view.
     */
    func endOfViewReachedFromIceberg(at index: Int) {
        if gameState == .running {
            game?.endOfViewReachedFromIceberg(at: index)
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     While game is running it will be detected that there is a collision between ship and iceberg.
     */
    func intersectionOfShipAndIceberg() {
        if gameState == .running {
            game.collisionBetweenShipAndIceberg()
            gameViewDelegate?.gameDidUpdate()
        }
    }

    /**
     Saving Player with user name for new highscore entry.
     */
    func nameForHighscoreEntry(userName: String, completion: (Error?) -> Void) {
        game.savePlayer(userName: userName) {error in
             if let error = error {
                completion(error)
             } else {
                completion(nil)
            }
        }
    }

    func countdownEnded() {
        gameState = .end
    }
}

// MARK: - Model related
private extension GameViewPresenter {

    typealias Iceberg = TitanicGame.Iceberg
    typealias Point = TitanicGame.Iceberg.Point
    typealias Size = TitanicGame.Iceberg.Size

    /**
     Creating new game model.
     
     - Parameter icebergs: icebergs from game view
     
     - Returns: a titanic game
     */
    private func createGameModel(from icebergs: [ImageView]) -> TitanicGame {
        var modelIcebergs = [TitanicGame.Iceberg]()
        icebergs.forEach {icebergView in
            let point = Point(
                xCoordinate: Double(icebergView.frame.origin.x),
                yCoordinate: Double(icebergView.frame.origin.y))
            let size = Size(
                width: Double(icebergView.frame.size.width),
                height: Double(icebergView.frame.size.height))
            let iceberg = Iceberg(origin: point, size: size)
            modelIcebergs.append(iceberg)
        }
        return TitanicGame(icebergs: modelIcebergs)
    }

    /**
     Receiving notification when game did end.
     */
    private func setupSubscriberForGameEnd() {

        cancellableObserver = NotificationCenter.default.publisher(
            for: .GameDidEnd,
            object: game)
            .sink {[weak self] _ in

                self?.gameState = .end
        }
    }
}

// MARK: - GameView related
extension GameViewPresenter {

    /**
     Creates, presents and set up dependencies in GameViewController.
     
     - Parameter viewController: View Controller which presents GameView Controller
     */
    func presentGameView(in viewController: UIViewController) {

        let gameVC = GameViewController(icebergs: icebergs, ship: ship, gameViewPresenter: self)
        gameVC.view.backgroundColor = .white
        gameViewDelegate = gameVC
        gameState = .new

        if let navigationController = viewController.navigationController {
            navigationController.pushViewController(gameVC, animated: true)

        } else {
            let navigationController = UINavigationController(rootViewController: gameVC)
            viewController.present(navigationController, animated: true)
        }
    }

    /**
     Create icebergs with initial coordinates.
     */
    private func setUpIcebergs() -> [ImageView] {
        if let width = UIApplication.shared.windows.first?.frame.width {
            let maxIcebergWidth = width / CGFloat(icebergHorizontalCount)
            var horizontalOffset: CGFloat = 0
            var icebergViewArray = [ImageView]()

            for index in 0..<icebergHorizontalCount * 2 {
                let icebergView = ImageView()
                icebergView.image = icebergImage
                icebergView.backgroundColor = .clear

                let verticalSpaceBetweenIcebergs =
                    icebergView.imageSize.height + icebergVerticalOffset * ship.imageSize.height
                if index.isMultiple(of: icebergHorizontalCount) {horizontalOffset = 0}

                //yCoordinates have to be out of visble y Axis
                icebergView.frame = CGRect(
                    x: maxIcebergWidth/2 - icebergView.imageSize.width/2 + horizontalOffset,
                    y: -(CGFloat(index) * verticalSpaceBetweenIcebergs) - icebergView.imageSize.height,
                    width: icebergView.imageSize.width,
                    height: icebergView.imageSize.height)

                horizontalOffset += maxIcebergWidth
                icebergViewArray.append(icebergView)
            }
            return icebergViewArray
        }
        return [ImageView]()
    }
}

// MARK: - Constants
extension GameViewPresenter {

    private var icebergImageName: String {"iceberg"}
    private var shipImageName: String {"ship"}
    private var icebergHorizontalCount: Int {3}
    private var icebergVerticalOffset: CGFloat {1.5}
}
