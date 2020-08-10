//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SpriteKit
import Combine

class GameViewController: UIViewController {

     // MARK: - Properties
    @IBOutlet private weak var gameView: GameView!
    @IBOutlet private weak var gameControlBtn: UIBarButtonItem!

    private lazy var gameViewPresenter = setupGameViewPresenter()
    private lazy var startEndView = StartEndView(frame: gameView.frame)
    private lazy var pauseView = PauseView(frame: gameView.frame)

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

    // MARK: - Button Action
    @IBAction private func changeGameStatus(_ sender: UIBarButtonItem) {
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
        gameView.addSubviews()
        setupSubscriber()
        gameViewPresenter.setGameViewDelegate(gameViewDelegate: self)
        gameView.gameCountdownTimer.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        preparationCountdownTimer?.cancel()
        gameView.gameCountdownTimer.reset()
    }
}

 // MARK: - Private methods to control view logic
private extension GameViewController {

    private func setupGameViewPresenter() -> GameViewPresenter {
        var icebergInitXOrigin = [Double]()
        var icebergInitYOrigin = [Double]()
        var icebergSize = [(width: Double, height: Double)]()
        gameView.icebergs.forEach {iceberg in
            icebergInitXOrigin.append((Double(iceberg.frame.origin.x)))
            icebergInitYOrigin.append((Double(iceberg.frame.origin.y)))
            icebergSize.append((Double(iceberg.frame.width), Double(iceberg.frame.height)))
        }
        return GameViewPresenter(
            icebergInitXOrigin: icebergInitXOrigin,
            icebergInitYOrigin: icebergInitYOrigin,
            icebergSize: icebergSize)
    }

    private func setupSubscriber() {
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .IcebergDidReachEndOfView)
            .sink {[weak self] notification in
                self?.icebergDidReachEndOfViewNotification(notification)
        })
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .ShipDidIntersectWithIceberg)
            .sink {[weak self] _ in
                self?.intersectionOfShipAndIceberg()
        })
    }

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

    private func runningPreparationCountdown() {
        if startEndView.label.text == AppStrings.Game.goLblTxt {
            removeStartEndViewWithAnimation()
            gameView.gameCountdownTimer.start(
                beginningValue: gameViewPresenter.game.countdownBeginningValue,
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

    private func intersectionOfShipAndIceberg() {
        UIDevice.vibrate()
        intersectionAnimation()
        gameViewPresenter.intersectionOfShipAndIceberg()
    }

    private func icebergDidReachEndOfViewNotification(_ notification: Notification) {
        if let dict = notification.userInfo as NSDictionary?,
            let icebergView = dict[AppStrings.UserInfoKey.iceberg] as? ImageView {
            if let index = gameView.icebergs.firstIndex(of: icebergView) {
                gameViewPresenter.reachingEndOfViewOfIceberg(at: index)
            }
        }
    }

    @objc private func moveIcebergs() {
        gameViewPresenter.moveIcebergsToScreenEnd()
    }

    private func updateViewFromModel() {

        guard let model = gameViewPresenter.game else {
            return
        }
        model.icebergs.enumerated().forEach({iceberg in
            gameView.icebergs[iceberg.offset].center = CGPoint(
                x: model.icebergs[iceberg.offset].center.xCoordinate,
                y: model.icebergs[iceberg.offset].center.yCoordinate)
        })

        if gameViewPresenter.gameStatus == .running {
            gameView.scoreStackView.knotsLbl.text = AppStrings.Game.knotsLblTxt + model.knots.description
        } else {
            gameView.scoreStackView.knotsLbl.text = AppStrings.Game.knotsLblTxt + "0"
        }
        gameView.scoreStackView.drivenSeaMilesLbl.text =
            AppStrings.Game.drivenSeaMilesLblTxt + model.drivenSeaMiles.description
        gameView.scoreStackView.crashCountLbl.text =
            AppStrings.Game.crashesLblTxt + model.crashCount.description
    }

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

// MARK: - Private methods for setting up layout and animation
private extension GameViewController {

    private func intersectionAnimation() {
        displayLink?.isPaused = true
        let smokeView = SmokeView(frame: gameView.frame)
        gameView.addSubview(smokeView)
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOfIntersectionAnimation) {
            smokeView.removeFromSuperview()
            if self.gameViewPresenter.gameStatus != .pause {
                self.displayLink?.isPaused = false
            }
        }
    }

    private func sliderAnimation() {
        UIView.transition(
            with: self.gameView.horizontalSlider,
            duration: self.interval,
            options: [],
            animations: {
                self.lookingForRandomSliderValue()
        })
    }

    private func addStartEndViewWithAnimation(lblText: String) {
        gameView.addSubview(startEndView)
        startEndView.label.text = lblText
        UIView.animate(withDuration: interval) {
            self.startEndView.alpha = 0.8
        }
    }

    private func removeStartEndViewWithAnimation() {
        UIView.animate(
            withDuration: interval/2,
            animations: {self.startEndView.alpha = 0.0},
            completion: {_ in
                self.startEndView.removeFromSuperview()
        })
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
    func gameDidEndWithoutHighscore() {
         gameView.gameCountdownTimer.reset()
         addStartEndViewWithAnimation(lblText: AppStrings.Game.gameOverLblTxt)
    }

    func gameDidEndWithHighscore() {
        gameView.gameCountdownTimer.reset()
        addStartEndViewWithAnimation(lblText: AppStrings.Game.youWinLblTxt)
        showAlertForHighscoreEntry()
    }
}

// MARK: - CountdownTimer Delegate Methods
extension GameViewController: SRCountdownTimerDelegate {

    func timerDidStart(sender: SRCountdownTimer) {
        displayLink = CADisplayLink(target: self, selector: #selector(moveIcebergs))
        displayLink?.add(to: .current, forMode: .common)
    }

    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        self.gameViewPresenter.gameCountdownTimerDidUpdate()
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
        invalidateDisplayLink()
    }
}

// MARK: - Constants
extension GameViewController {

    private var durationOfIntersectionAnimation: Double {1.5}
    private var interval: Double {1}
    private var reminderCount: Int {10}
    private var one: String {"1"}
}
