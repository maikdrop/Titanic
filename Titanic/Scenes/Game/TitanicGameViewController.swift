/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Combine

class TitanicGameViewController: UIViewController {

    // MARK: - Properties
    private var gameViewPresenter: TitanicGameViewPresenter
    private lazy var gameView: TitanicGameView = TitanicGameView(
        frame: view.frame,
        icebergsInARow: gameViewPresenter.icebergsInARow,
        rowsOfIcebergs: gameViewPresenter.rowsOfIcebergs)

    private var cancellableObserver = [Cancellable?]()
    private var displayLink: CADisplayLink?

    private lazy var gameControlBtn = UIBarButtonItem(
          image: UIImage(systemName: controlBtnName),
          style: .done,
          target: self,
          action: #selector(changeGameState))

    // MARK: - Button action to change game state
    @objc private func changeGameState(_ sender: UIBarButtonItem) {
        if let state = gameViewPresenter.gameState {
            NewGameStatePresenter(state: state) { [unowned self] outcome in
                switch outcome {
                case .accepted(let newState):
                    self.gameViewPresenter.changeGameState(to: newState)
                case .rejected:
                    break
                }
            }.present(in: self)
        }
    }

    // MARK: - Create a game view
    init(gameViewPresenter: TitanicGameViewPresenter) {
        self.gameViewPresenter = gameViewPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        gameView.gameCountdownTimer.reset()
    }
}

// MARK: - Calling game intents
private extension TitanicGameViewController {

    /**
     Notification from game view.
     
     - Parameter notification: Notification when ship intersects with iceberg
     */
    private func intersectionOfShipAndIceberg(_ notification: Notification) {
        UIDevice.vibrate()
        gameViewPresenter.intersectionOfShipAndIceberg()
        if let dict = notification.userInfo as NSDictionary?,
            let intersectionPoint = dict[AppStrings.UserInfoKey.ship] as? CGPoint {
            intersectionAnimation(at: intersectionPoint)
        }
    }

    /**
     Notification from game view.
     
     - Parameter notification: Notification when an iceberg reached end of view
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

        gameView.scoreStackView.knotsLbl.text = AppStrings.Game.knotsLblTxt + gameViewPresenter.knots.description
        gameView.scoreStackView.drivenSeaMilesLbl.text =
            AppStrings.Game.drivenSeaMilesLblTxt + gameViewPresenter.drivenSeaMiles.description
        gameView.scoreStackView.crashCountLbl.text =
            AppStrings.Game.crashesLblTxt + gameViewPresenter.crashCount.description
    }

    /**
     Shows an alert for highscore entry where an user can enter their name. After accepting the current highscore list shows up.
     */
    private func showAlertForHighscoreEntry() {

        NewHighscoreEntryPresenter(
            title: AppStrings.NewHighscoreEntryAlert.title,
            message: AppStrings.NewHighscoreEntryAlert.message) {[unowned self] outcome in
                switch outcome {
                case .accepted(let userName):
                    self.gameViewPresenter.nameForHighscoreEntry(userName: userName) {error in
                        if let error = error {
                            self.alertError(title: AppStrings.ErrorAlert.title, message: error.localizedDescription)
                            return
                        }
                        HighscoreListPresenter().present(in: self)
                    }
                case .rejected:
                    break
                }
        }.present(in: self)
    }
}

// MARK: - UI logic to prepare and start the game
private extension TitanicGameViewController {

    /**
     Creating and adding preparation view in order to inform user when game will start.
     */
    private func startPreparationCoutdown() {
        gameControlBtn.isEnabled = false
        let min = gameView.horizontalSlider.minimumValue
        let max = gameView.horizontalSlider.maximumValue
        let preparationVC = PreparationCountdownViewController(
            preparationCountdown: preparationCountdown,
            animationInterval: interval) { [unowned self] counter in
                if counter == 0 {
                    self.animateSettingRandomSliderValue(within: min, and: max)
                } else {
                    self.animateSettingSliderValue(to: min, or: max)
                }
        }
        add(preparationVC)
    }

    /**
     Animates setting of random slider value within a range.
     
     - Parameter min: minimum value
     - Parameter max: maximum value
    */
    private func animateSettingRandomSliderValue(within min: Float, and max: Float) {
        UIView.animate(
            withDuration: interval,
            animations: {
                let newSliderValue = Float.random(in: min...max)
                self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
                self.gameView.horizontalSlider.sendActions(for: .valueChanged)
            },
            completion: {_ in
                self.preparationCountdownEnded()
            })
    }

    /**
     Animates setting of slider value to a given value.
     
     - Parameter min: minimum value
     - Parameter max: maximum value
     */
    private func animateSettingSliderValue(to min: Float, or max: Float) {
        UIView.animate(withDuration: self.interval, animations: {
            let newSliderValue = self.gameView.horizontalSlider.value == max ? min : max
            self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
            self.gameView.horizontalSlider.sendActions(for: .valueChanged)
        })
    }

    /**
     When preparation countdown ends game countdown starts after 1 second of delay.
    */
    private func preparationCountdownEnded() {
        gameControlBtn.isEnabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + interval/2) {
            self.gameView.gameCountdownTimer.start(
                beginningValue: self.gameViewPresenter.countdownBeginningValue,
                interval: self.interval,
                lastSecondsReminderCount: self.reminderCount)
        }
    }
}

// MARK: - Utility stuff
extension TitanicGameViewController {

    /**
     Creates smoke animation when ship and iceberg intersects.
     
     - Parameter intersectionPoint: coordinates of intersection
     */
    private func intersectionAnimation(at intersectionPoint: CGPoint) {

        guard gameView.smokeView == nil else {
            return
        }
        displayLink?.isPaused = true
        gameView.setSmokeView(at: intersectionPoint)
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOfIntersectionAnimation) {
            self.gameView.smokeView?.removeFromSuperview()
            if !self.gameView.subviews.contains(self.gameView.pauseView) {self.displayLink?.isPaused = false}
        }
    }

    /**
     Setting up subscribers to receive notifications when ship and iceberg intersect and when an iceberg reaches the end of view.
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

    private func setupGameView() {
        view.addSubview(gameView)
        gameView.setupGameView()
        gameView.gameCountdownTimer.delegate = self
        setupIcebergSubscriber()
    }

    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - GameViewPresenter Delegate Methods
extension TitanicGameViewController: TitanicGamePresenterDelegate {

    func gameDidUpdate() {
        updateViewFromModel()
    }

    func gameDidStart() {
        gameView.gameCountdownTimer.reset()
        gameDidUpdate()
        children.forEach({$0.remove()})
        startPreparationCoutdown()
    }

    func gameDidPause() {
        gameView.gameCountdownTimer.pause()
        gameView.addSubview(gameView.pauseView)
    }

    func gameDidResume() {
        gameView.gameCountdownTimer.resume()
        gameView.pauseView.removeFromSuperview()
    }
    func gameEndedWithoutHighscore() {
        gameView.gameCountdownTimer.reset()
        let gameEndVC = GameEndViewController(statusText: AppStrings.Game.gameOverLblTxt, animationInterval: interval)
        add(gameEndVC)
    }

    func gameEndedWithHighscore() {
        if presentedViewController is UIAlertController {
            presentedViewController?.dismissWithAnimation()
        }
        gameView.gameCountdownTimer.reset()
        let gameEndVC = GameEndViewController(statusText: AppStrings.Game.youWinLblTxt, animationInterval: interval)
        add(gameEndVC)
        showAlertForHighscoreEntry()
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
extension TitanicGameViewController {

    private var preparationCountdown: Int {3}
    private var durationOfIntersectionAnimation: Double {1.5}
    private var interval: Double {1}
    private var reminderCount: Int {10}
    private var one: String {"1"}
    private var controlBtnName: String {"control"}
}
