/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import SpriteKit
import Combine

class GameViewController: UIViewController {

    // MARK: - Properties
    private lazy var gameControlBtn = UIBarButtonItem(
        image: UIImage(systemName: controlBtnName),
        style: .done,
        target: self,
        action: #selector(changeGameStatus))

    var gameViewPresenter: GameViewPresenter! {
        didSet {
            gameViewPresenter.changeGameStatus(to: AppStrings.GameStatus.new)
        }
    }
    private lazy var gameView: GameView = GameView(frame: view.frame, icebergs: icebergs, ship: ship)
    private var icebergs: [ImageView]
    private var ship: ImageView

    private lazy var startEndView = StartEndView(frame: gameView.frame)
    private lazy var pauseView = PauseView(frame: gameView.frame)
    private var smokeView: SKView?

    private var cancellableObserver = [Cancellable?]()
    private var preparationCountdownTimer: Cancellable?
    private var displayLink: CADisplayLink?

    private var preparationCountdownForUser = 3 {
        didSet {
            if preparationCountdownForUser == 0 {
                preparationCountdownForUser = 3
            }
        }
    }

    // MARK: - Button action to change game status
    @objc private func changeGameStatus(_ sender: UIBarButtonItem) {
        if let status = gameViewPresenter.gameStatus {
            NewGameStatusPresenter(status: status) { [unowned self] outcome in
                switch outcome {
                case .accepted(let newStatus):
                    self.gameViewPresenter.changeGameStatus(to: newStatus)
                case .rejected:
                    break
                }
            }.present(in: self)
        }
    }

    // MARK: - Create a GameView Controller
    init(icebergs: [ImageView], ship: ImageView) {
        self.icebergs = icebergs
        self.ship = ship
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT GameViewController")
        cancellableObserver.forEach({observer in
            observer?.cancel()
        })
    }
}

// MARK: - Default Methods
extension GameViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGameView()
        navigationItem.rightBarButtonItem = gameControlBtn
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        preparationCountdownTimer?.cancel()
        gameView.gameCountdownTimer.reset()
    }
}

// MARK: - UI stuff in order to prepare the game
private extension GameViewController {

    /**
     Creating preparation countdown timer to inform user when a new game starts.
     */
    private func startPreparationCoutdown() {
        gameControlBtn.isEnabled = false
        if gameView.subviews.contains(startEndView) {
            startEndView.label.text = String(preparationCountdownForUser)
        } else {
            addStartEndViewWithAnimation(lblText: String(preparationCountdownForUser))
        }
        preparationCountdownTimer = Timer.publish(
            every: interval,
            on: .main,
            in: .common)
            .autoconnect().sink { [weak self] _ in
            self?.runningPreparationCountdown()
        }
    }

    /**
     Creating a game countdown timer when preparation countdown has run down.
     */
    private func runningPreparationCountdown() {
        if startEndView.label.text == AppStrings.Game.goLblTxt {
            removeStartEndViewWithAnimation()
            gameView.gameCountdownTimer.start(
                beginningValue: gameViewPresenter.countdownBeginningValue,
                interval: interval,
                lastSecondsReminderCount: reminderCount)
            preparationCountdownTimer?.cancel()
            gameControlBtn.isEnabled = true
        } else {
            preparationCountdownForUser -= 1
            startEndView.label.text = startEndView.label.text == one ?
                AppStrings.Game.goLblTxt : preparationCountdownForUser.description
            sliderAnimation()
        }
    }

    /**
     Looking for random slider vlaue while preparation countdown is running.
     */
    private func lookingForRandomSliderValue() {
        var newSliderValue: Float = 0
        if startEndView.label.text == AppStrings.Game.goLblTxt {
            newSliderValue = Float.random(
                in: self.gameView.horizontalSlider.minimumValue...self.gameView.horizontalSlider.maximumValue)
        } else {
            newSliderValue = self.gameView.horizontalSlider.value == self.gameView.horizontalSlider.maximumValue ?
                self.gameView.horizontalSlider.minimumValue:self.gameView.horizontalSlider.maximumValue
        }
        self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
        self.gameView.horizontalSlider.sendActions(for: .valueChanged)
    }
}

 // MARK: - Game Intents and UI logic
private extension GameViewController {

    /**
     When ship and iceberg intersect device vibrates, an intersection animiation is shown and the presenter is called to decide what happens next.
     */
    private func intersectionOfShipAndIceberg() {
            UIDevice.vibrate()
            intersectionAnimation()
            gameViewPresenter.intersectionOfShipAndIceberg()
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
        icebergs.enumerated().forEach({iceberg in
            gameView.icebergs[iceberg.offset].center = iceberg.element
        })

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

// MARK: - Animation stuff
private extension GameViewController {

    /**
     Creates smoke animation when ship and iceberg intersects.
     */
    private func intersectionAnimation() {

        guard smokeView == nil else {
            return
        }
        displayLink?.isPaused = true
        smokeView = SmokeView(frame: gameView.frame)
        gameView.addSubview(smokeView!)
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOfIntersectionAnimation) {
            self.smokeView?.removeFromSuperview()
            self.smokeView = nil
            if !self.gameView.subviews.contains(self.pauseView) {self.displayLink?.isPaused = false}
        }
    }

    /**
     Animates movement of slider from minimum to maximum.
     */
    private func sliderAnimation() {
        UIView.transition(
            with: self.gameView.horizontalSlider,
            duration: self.interval,
            options: [],
            animations: {
                self.lookingForRandomSliderValue()
        })
    }

    /**
     Animates the adding of start and end view.
    */
    private func addStartEndViewWithAnimation(lblText: String) {
        gameView.addSubview(startEndView)
        startEndView.label.text = lblText
        UIView.animate(withDuration: interval) {
            self.startEndView.alpha = 0.8
        }
    }

    /**
     Animates the removing of start and end view.
     */
    private func removeStartEndViewWithAnimation() {
        UIView.animate(
            withDuration: interval/2,
            animations: {self.startEndView.alpha = 0.0},
            completion: {_ in
                self.startEndView.removeFromSuperview()
        })
    }
}

// MARK: - Utility stuff
extension GameViewController {

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
            .sink {[weak self] _ in
                self?.intersectionOfShipAndIceberg()
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
extension GameViewController: GameViewDelegate {

    func gameDidUpdate() {
        updateViewFromModel()
    }

    func gameDidStart() {
        gameView.gameCountdownTimer.reset()
        gameDidUpdate()
        startPreparationCoutdown()
    }

    func gameDidPause() {
        gameView.gameCountdownTimer.pause()
        gameView.addSubview(pauseView)
    }

    func gameDidResume() {
        gameView.gameCountdownTimer.resume()
        pauseView.removeFromSuperview()
    }
    func gameEndedWithoutHighscore() {
        gameView.gameCountdownTimer.reset()
        addStartEndViewWithAnimation(lblText: AppStrings.Game.gameOverLblTxt)
    }

    func gameEndedWithHighscore() {
        if presentedViewController is UIAlertController {
            presentedViewController?.dismissWithAnimation()
        }
        gameView.gameCountdownTimer.reset()
        addStartEndViewWithAnimation(lblText: AppStrings.Game.youWinLblTxt)
        showAlertForHighscoreEntry()
    }
}

// MARK: - SRCountdownTimer Delegate Methods
extension GameViewController: SRCountdownTimerDelegate {

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
extension GameViewController {

    private var durationOfIntersectionAnimation: Double {1.5}
    private var interval: Double {1}
    private var reminderCount: Int {10}
    private var one: String {"1"}
    private var controlBtnName: String {"control"}
}
