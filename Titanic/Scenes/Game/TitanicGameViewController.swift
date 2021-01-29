/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Combine

// swiftlint:disable file_length
class TitanicGameViewController: UIViewController {

    // MARK: - Properties
    private var gameViewPresenter: TitanicGameViewPresenter
    private lazy var gameView =
        TitanicGameView(frame: view.frame,
                        icebergsInARow: gameViewPresenter.icebergsInARow,
                        rowsOfIcebergs: gameViewPresenter.rowsOfIcebergs)

    private var cancellableObserver = [Cancellable?]()
    private var displayLink: CADisplayLink?
    private var gameDelayTimer: Timer?
    private var randomSliderValueAnimator: UIViewPropertyAnimator?
    private lazy var pauseView: PauseView = {
        let pauseView = PauseView(frame: gameView.frame)
        pauseView.addGestureRecognizer(createTapGesture())
        return pauseView
    }()
    private lazy var gameControlBtn = UIBarButtonItem(
        title: "",
        image: UIImage(systemName: systemImageName),
        primaryAction: nil,
        menu: menuForControlBtn())

    // MARK: - Create a game view
    init(gameViewPresenter: TitanicGameViewPresenter) {
        self.gameViewPresenter = gameViewPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented")}

    deinit {
        print("DEINIT TitanicGameViewController")
        cancellableObserver.forEach {observer in
            observer?.cancel()
        }
    }
}

// MARK: - Default Methods
extension TitanicGameViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameView()
        gameViewPresenter.attachView(self)
        gameViewPresenter.gameViewDidLoad(icebergs: gameView.icebergs)
        navigationItem.rightBarButtonItem = gameControlBtn
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        randomSliderValueAnimator?.stopAnimation(true)
        gameView.gameCountdownTimer.reset()
        gameDelayTimer?.invalidate()
    }
}

// MARK: - Private game intents
private extension TitanicGameViewController {

    /**
     Notification from the game view.
     
     - Parameter notification: The notification when the ship intersects with a iceberg.
     */
    private func intersectionOfShipAndIceberg(_ notification: Notification) {
        if gameViewPresenter.gameState == .running {
            UIDevice.vibrate()
            gameViewPresenter.intersectionOfShipAndIceberg()
            if let dict = notification.userInfo as NSDictionary?,
                let intersectionPoint = dict[AppStrings.UserInfoKey.ship] as? CGPoint {
                intersectionAnimation(at: intersectionPoint)
            }
        }
    }

    /**
     Notification from the game view.
     
     - Parameter notification: The notification when an iceberg reached the end of the view.
     */
    private func icebergReachedEndOfViewNotification(_ notification: Notification) {
        if let dict = notification.userInfo as NSDictionary?,
            let icebergView = dict[AppStrings.UserInfoKey.iceberg] as? ImageView {
            if let index = gameView.icebergs.firstIndex(of: icebergView) {
                gameViewPresenter.endOfViewReachedFromIceberg(at: index)
            }
        }
    }

    @objc private func moveIcebergs() {
        gameViewPresenter.moveIcebergsVertically()
    }

    /**
     Updating iceberg coordinates and score labels from model data.
     */
    private func updateViewFromModel() {
        let icebergs = gameViewPresenter.icebergsToDisplay
        icebergs.enumerated().forEach {iceberg in
            let center = CGPoint(x: iceberg.element.xCenter, y: iceberg.element.yCenter)
            gameView.icebergs[iceberg.offset].center = center
        }

        gameView.scoreStackView.knotsLbl.text = AppStrings.Game.knotsLblTxt + ": " + gameViewPresenter.knots.description

        let formattedString = AppStrings.Game.drivenSeaMilesLblTxt + ": " + "%.2f"
        gameView.scoreStackView.drivenSeaMilesLbl.text =
            String(format: formattedString, gameViewPresenter.drivenSeaMiles)

        gameView.scoreStackView.crashCountLbl.text =
            AppStrings.Game.crashesLblTxt + ": " + gameViewPresenter.crashCount.description
    }

    /**
     Shows an alert for a highscore entry. The user can enter their name. After accepting, the current highscore list shows up.
     */
    private func showAlertForHighscoreEntry() {
        NewHighscoreEntryPresenter(
            title: AppStrings.NewHighscoreEntryAlert.title,
            message: AppStrings.NewHighscoreEntryAlert.message) {[unowned self] outcome in
                switch outcome {
                case .accepted(let userName):
                    self.gameViewPresenter.nameForHighscoreEntry(userName: userName) {error in
                        if let dataHandlingError = error as? DataHandlingError {
                            self.infoAlert(
                                title: AppStrings.ErrorAlert.title,
                                message: dataHandlingError.getErrorMessage())
                            return
                        }
                        HighscoreListNaviPresenter().present(in: self)
                    }
                case .rejected:
                    break
                }
        }.present(in: self)
    }

    /**
     Saves game and shows alert if saving was successful or not.
     */
    private func saveGame() {
        gameView.gameCountdownTimer.pause()

        self.gameViewPresenter.saveGame(sliderValue: gameView.horizontalSlider.value,
                                        timerCount: gameView.gameCountdownTimer.currentCounterValue) { error in
            if let dataHandlingError = error as? DataHandlingError {
                self.infoAlert(
                    title: AppStrings.ErrorAlert.title,
                    message: dataHandlingError.getErrorMessage())
            } else {
                self.infoAlert(title: AppStrings.GameControl.savedSuccessfully, message: "")
            }
        }
    }
}

// MARK: - UI logic to prepare, start and, finish the game.
private extension TitanicGameViewController {

    /**
     Creates and adds the preparation countdown view in order to inform the user when the game will start.
     
     - Description: While adding the preparation view, the changing of the alpha value is animated.
     */
    private func startPreparationCoutdown() {
        gameControlBtn.isEnabled = false
        let min = gameView.horizontalSlider.minimumValue
        let max = gameView.horizontalSlider.maximumValue
        let preparationVC = PreparationCountdownViewController(
            preparationCountdown: preparationCountdown,
            animationInterval: interval) { [weak self] counter in
            if counter == 0 {
                self?.animateSettingRandomSliderValue(within: min, and: max)
            } else {
                self?.animateSettingSliderValue(to: min, or: max)
            }
        }
        addViewForPreparationCountdown(preparationVC: preparationVC)
    }

    /**
     Animates the setting of the random slider value within a range.
     
     - Parameter min: The minimum value of the range.
     - Parameter max: The maximum value of the range.
    */
    private func animateSettingRandomSliderValue(within min: Float, and max: Float) {
        randomSliderValueAnimator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: interval,
            delay: 0,
            options: [],
            animations: {
                let newSliderValue = self.gameViewPresenter.getSliderValue(within: min, and: max)
                self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
                self.gameView.horizontalSlider.sendActions(for: .valueChanged)
            },
            completion: {_ in self.gameViewPresenter.viewPreparationEnded()})
    }

    /**
     Animates the setting of the slider value to a given value.
     
     - Parameter min: The minimum value that will be set.
     - Parameter max: The maximum value that will be set.
     */
    private func animateSettingSliderValue(to min: Float, or max: Float) {
        UIView.animate(withDuration: interval) {
            let newSliderValue = self.gameView.horizontalSlider.value == max ? min : max
            self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
            self.gameView.horizontalSlider.sendActions(for: .valueChanged)
        }
    }

    /**
     Starts a short delay timer in order to start the game countdown timer afterwards.
    */
    private func startDelayTimer() {

        gameDelayTimer = Timer.scheduledTimer(
            timeInterval: interval/2,
            target: self,
            selector: #selector(startGameTimer),
            userInfo: nil,
            repeats: false)
    }

    /**
     Starts the game countdown timer and enables the game control button.
    */
    @objc private func startGameTimer() {
        gameControlBtn.isEnabled = true
        gameView.gameCountdownTimer.start(
            beginningValue: gameViewPresenter.gameConfig.timerCount,
            interval: interval,
            lastSecondsReminderCount: reminderCount)
    }

    /**
     Shows and animates the preparation countdown view before the game starts.
     
     - Parameter preparationVC: The displayed view controller.
    */
    private func addViewForPreparationCountdown(preparationVC: PreparationCountdownViewController) {
        if let last = children.last as? GameEndViewController {
            preparationVC.view.alpha = last.view.alpha
        } else {
            preparationVC.view.alpha = 0
        }
        children.forEach({$0.remove()})
        add(preparationVC)
        UIView.animate(withDuration: interval) {
            preparationVC.view.alpha = self.childViewAlpha
        }
    }

    /**
     Shows and animates the status view after the end of the game.
     
     - Parameter statusText: The displayed status text.
    */
    private func addViewForGameEnd(statusText: String) {
        gameView.gameCountdownTimer.reset()
        let gameEndVC = GameEndViewController(statusText: statusText, animationInterval: interval)
        gameEndVC.view.alpha = 0
        add(gameEndVC)
        UIView.animate(withDuration: interval) {
            gameEndVC.view.alpha = self.childViewAlpha
        }
    }

    /**
     Creates a smoke animation when the ship and a iceberg intersect.
     
     - Parameter intersectionPoint: The coordinates of the intersection point.
     */
    private func intersectionAnimation(at intersectionPoint: CGPoint) {
        guard gameView.smokeView == nil else {
            return
        }
        displayLink?.isPaused = true
        gameView.setSmokeView(at: intersectionPoint)
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOfIntersectionAnimation) {
            self.gameView.smokeView?.removeFromSuperview()
            if !self.gameView.subviews.contains(self.pauseView) && self.gameViewPresenter.gameState != .save {
                self.displayLink?.isPaused = false
            }
        }
    }
}

// MARK: - Utility and setup stuff
private extension TitanicGameViewController {

    /**
     Setting up the game view.
     */
    private func setupGameView() {
        view.addSubview(gameView)
        gameView.addGestureRecognizer(createTapGesture())
        gameView.setupGameView()
        gameView.gameCountdownTimer.delegate = self
        setupIcebergSubscriber()
    }

    /**
     Creates a menu for a button accordingly to the current game state and handles the actions in order to choose a new state.
     
     - Returns: the created menu
     */
    private func menuForControlBtn() -> UIMenu? {

        if let state = gameViewPresenter.gameState {

            return GameStateMenuPresenter(currentGameState: state, handler: { [weak self] outcome in
                switch outcome {
                case .accepted(let newState):
                    if newState == TitanicGameViewPresenter.GameState.save.stringValue {
                        self?.saveGame()
                    } else {
                        self?.gameViewPresenter.changeGameState(to: newState)
                    }
                case .rejected:
                    break
                }
            }).buttonMenu()
        }
        return nil
    }

    /**
     Setting up the subscribers to receive notifications when ship and iceberg intersect and when an iceberg reaches the end of view.
     */
    private func setupIcebergSubscriber() {
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .IcebergReachedEndOfView)
            .sink {[weak self] notification in
                self?.icebergReachedEndOfViewNotification(notification)
        })
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .ShipDidIntersectWithIceberg)
            .sink {[weak self] notification in
                self?.intersectionOfShipAndIceberg(notification)
        })
    }

    /**
     Creates a double tap gesture recognizer.
     
     - Returns: gesture recognizer
     */
    private func createTapGesture() -> UITapGestureRecognizer {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        recognizer.numberOfTapsRequired = 2
        return recognizer
    }

    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    /**
     Target action of double tap gesture recognizer.
     */
    @objc private func doubleTapped() {

        switch gameViewPresenter.gameState {
        case .running:
            self.gameViewPresenter.changeGameState(to: .pause)
        case .pause:
            self.gameViewPresenter.changeGameState(to: .resume)
        default:
            break
        }
    }
}

// MARK: - GameViewPresenter Delegate Methods
extension TitanicGameViewController: TitanicGameViewPresenterDelegate {

    func gameDidUpdate() {
        updateViewFromModel()
    }

    func gameDidPrepare() {
        gameView.icebergs.forEach { $0.alpha = gameObjectAlpha }
        gameView.gameCountdownTimer.reset()
        gameDidUpdate()
        startPreparationCoutdown()
    }

    func gameDidStart() {
        gameView.icebergs.forEach { $0.alpha = 1 }
        gameControlBtn.menu = menuForControlBtn()
        startDelayTimer()
    }

    func gameDidPause() {
        gameView.gameCountdownTimer.pause()
        gameView.addSubview(pauseView)
        gameControlBtn.menu = menuForControlBtn()
    }

    func gameDidResume() {
        gameView.gameCountdownTimer.resume()
        pauseView.removeFromSuperview()
        gameControlBtn.menu = menuForControlBtn()
    }
    func gameEndedWithoutHighscore() {
        gameView.icebergs.forEach { $0.alpha = gameObjectAlpha }
        gameControlBtn.menu = nil
        addViewForGameEnd(statusText: AppStrings.Game.gameOverLblTxt)
        gameControlBtn.menu = menuForControlBtn()
    }

    func gameEndedWithHighscore() {
        gameView.icebergs.forEach { $0.alpha = gameObjectAlpha }
        gameControlBtn.menu = nil
        addViewForGameEnd(statusText: AppStrings.Game.youWinLblTxt)
        showAlertForHighscoreEntry()
        gameControlBtn.menu = menuForControlBtn()
    }
}

// MARK: - SRCountdownTimer Delegate Methods
extension TitanicGameViewController: SRCountdownTimerDelegate {

    func timerDidStart(sender: SRCountdownTimer) {
        displayLink = CADisplayLink(target: self, selector: #selector(moveIcebergs))
        displayLink?.add(to: .current, forMode: .common)
    }

    func timerDidPause(sender: SRCountdownTimer) {
        displayLink?.isPaused = true
    }

    func timerDidResume(sender: SRCountdownTimer) {
        displayLink?.isPaused = false
    }

    func timerDidReset(sender: SRCountdownTimer) {
        invalidateDisplayLink()
    }

    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        gameViewPresenter.countdownEnded()
    }
}

// MARK: - Constants
private extension TitanicGameViewController {

    private var preparationCountdown: Int { 3 }
    private var durationOfIntersectionAnimation: Double { 1.5 }
    private var interval: Double { 1 }
    private var reminderCount: Int { 10 }
    private var gameObjectAlpha: CGFloat { 0.25 }
    private var childViewAlpha: CGFloat { 0.8 }
    private var one: String { "1" }
    private var systemImageName: String { AppStrings.ImageNames.gameController }
}
