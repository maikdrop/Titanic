//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SRCountdownTimer
import SpriteKit
import Combine

class GameViewController: UIViewController {
    
    @IBOutlet private weak var gameControlBtn: UIBarButtonItem!
    @IBAction private func changeGameStatus(_ sender: UIBarButtonItem) {
        if let status = gamePresenter.gameStatus {
            GameStatusPresenter(status: status, handler: { [unowned self] outcome in
                switch outcome {
                case .newStatus(let newStatus):
                    self.gamePresenter.changeGameStatus(to: newStatus)
                case .rejected:
                    break
                }
            }).present(in: self)
        }
    }
    @IBOutlet private weak var gameView: GameView!
    
    private var gamePresenter: GamePresenter! {
        didSet {
             gamePresenter?.delegate = self
        }
    }
    private var preparationCountdownForUser = 3 {
        didSet {
            if preparationCountdownForUser == 0 {
                preparationCountdownForUser = 3
            }
        }
    }
    
    private var cancellableObserver = [Cancellable?]()
    private var preparationTimer: Cancellable?
    private var displayLink: CADisplayLink?
    private lazy var startEndView = StartEndView(frame: gameView.frame)
    private lazy var pauseView = PauseView(frame: gameView.frame)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.addSubviews()
        gameView.countdownTimer.delegate = self
        setupGamePresenter()
        setupPublisher()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        preparationTimer?.cancel()
        gameView.countdownTimer.reset()
    }
    
     deinit {
        print("DEINIT GameViewController")
    }
    
    //MARK: - View Logic
    
    private func setupGamePresenter() {
        var icebergInitXOrigin = [Double]()
        var icebergInitYOrigin = [Double]()
        gameView.icebergs.forEach({iceberg in
            icebergInitXOrigin.append((Double(iceberg.frame.origin.x)))
            icebergInitYOrigin.append((Double(iceberg.frame.origin.y)))
        })
        if let iceberg = gameView.icebergs.first {
            gamePresenter = GamePresenter(
                icebergInitXOrigin: icebergInitXOrigin,
                icebergInitYOrigin: icebergInitYOrigin,
                icebergSize: (width: Double(iceberg.frame.width),
                height: Double(iceberg.frame.height)))
        }
    }
    
    private func setupPublisher() {
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .IcebergDidReachEndOfView)
            .sink() { [weak self] notification in
                self?.icebergDidReachEndOfViewNotification(notification)
        })
        cancellableObserver.append(NotificationCenter.default
            .publisher(for: .ShipDidIntersectWithIceberg)
            .sink() {[weak self] _ in
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
        preparationTimer = Timer.publish(every: interval, on: .main, in: .common).autoconnect().sink(receiveValue: { [weak self] _ in
            self?.runningPreparationCountdown()
        })
    }
    
    private func runningPreparationCountdown() {
        if startEndView.label.text == GO_COUNTDOWN_LBL_TXT {
            removeStartEndViewWithAnimation()
            gameView.countdownTimer.start(beginningValue: beginningValue, interval: interval, lastSecondsReminderCount: reminderCount)
            preparationTimer?.cancel()
            gameControlBtn.isEnabled = true
        } else {
            preparationCountdownForUser -= 1
           startEndView.label.text = startEndView.label.text == ONE_COUNTDOWN_LBL_TXT ? GO_COUNTDOWN_LBL_TXT : String(preparationCountdownForUser)
            sliderAnimation()
        }
    }
    
    private func lookingForRandomSliderValue() {
        var newSliderValue:Float = 0
        if startEndView.label.text == GO_COUNTDOWN_LBL_TXT {
            newSliderValue = Float.random(in: self.gameView.horizontalSlider.minimumValue...self.gameView.horizontalSlider.maximumValue)
        } else {
            newSliderValue = self.gameView.horizontalSlider.value == self.gameView.horizontalSlider.maximumValue ? self.gameView.horizontalSlider.minimumValue:self.gameView.horizontalSlider.maximumValue
        }
        self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
        self.gameView.horizontalSlider.sendActions(for: .valueChanged)
    }
    
    private func intersectionOfShipAndIceberg() {
        UIDevice.vibrate()
        intersectionAnimation()
        gamePresenter.intersectionOfShipAndIceberg()
    }
    
    private func icebergDidReachEndOfViewNotification(_ notification: Notification) {
        if let dict = notification.userInfo as NSDictionary?, let icebergView = dict[ICEBERG_VIEW_KEY] as? ImageView {
            if let index = gameView.icebergs.firstIndex(of: icebergView) {
                gamePresenter.icebergReachedBottom(at: index)
            }
        }
    }
    
    @objc private func moveIceberg() {
        gamePresenter.moveIcebergFromTopToBottom()
    }
    
    private func updateViewFromModel() {
        
        guard let model = gamePresenter.game else {
            return
        }
        model.icebergs.enumerated().forEach({iceberg in
            gameView.icebergs[iceberg.offset].center = CGPoint(
                x: model.icebergs[iceberg.offset].center.x,
                y: model.icebergs[iceberg.offset].center.y)
        })
    }

    private func updateScoreLabels() {
        gameView.scoreStackView.knotsLbl.text = KNOTS_LBL_TEXT + "\(gamePresenter.knots)"
        gameView.scoreStackView.drivenSeaMilesLbl.text = SEA_MILES_LBL_TXT + "\(gamePresenter.drivenSeaMiles)"
        gameView.scoreStackView.crashCountLbl.text = CRASH_COUNT_LBL_TXT + "\(gamePresenter.crashCount)"
    }
    
    private func showAlertForHighscoreEntry() {
        
        NewHighscoreEntryPresenter(
            title: ALERT_TITLE,
            message: ALERT_MESSAGE,
            acceptTitle: ALERT_TITLE_DONE_ACTION,
            rejectTitle: ALERT_TITLE_CANCEL_ACTION,
            handler: { [unowned self] outcome in
                switch outcome {
                    case .accepted(let userName):
                        self.gamePresenter.nameForHighscoreEntry(userName: userName)
                        HighscoreListPresenter().present(in: self)
                    case .rejected:
                        break
                }
            }
        ).present(in: self)
    }
}

// MARK: - Layout and Animation
extension GameViewController {
    
    private func intersectionAnimation() {
        displayLink?.isPaused = true
        let smokeView = SmokeView(frame: gameView.frame)
        gameView.addSubview(smokeView)
        DispatchQueue.main.asyncAfter(deadline: .now() + durationOfIntersectionAnimation, execute: {
            smokeView.removeFromSuperview()
            if self.gamePresenter.gameStatus != .pause {
                self.displayLink?.isPaused = false
            }
        })
    }
    
    private func sliderAnimation() {
        UIView.transition(
            with: self.gameView.horizontalSlider,
            duration:  self.interval,
            options: [],
            animations: {
                self.lookingForRandomSliderValue()
        })
    }
    
    private func addStartEndViewWithAnimation(lblText: String){
        gameView.addSubview(startEndView)
        startEndView.label.text = lblText
        UIView.animate(withDuration: interval) {
            self.startEndView.alpha = 0.8
        }
    }
    
    private func removeStartEndViewWithAnimation() {
        UIView.animate(
            withDuration: interval/2,
            animations: {
             self.startEndView.alpha = 0.0
        }, completion: {finished in
            self.startEndView.removeFromSuperview()
        })
    }
}

// MARK: - Presenter Delegate Methods
extension GameViewController: GamePresenterDelegate {
    
    func gameDidUpdate() {
        updateViewFromModel()
        updateScoreLabels()
    }
    
    func gameDidStart() {
        sliderAnimation()
        startPreparationCoutdown()
    }
    
    func gameDidPause() {
        gameView.countdownTimer.pause()
        gameView.addSubview(pauseView)
    }
    
    func gameDidResume() {
        gameView.countdownTimer.resume()
        pauseView.removeFromSuperview()
    }
    
    func gameDidReset() {
        gameView.countdownTimer.reset()
        addStartEndViewWithAnimation(lblText: GAME_OVER)
    }
    
    func gameDidEndWithoutHighscore() {
        addStartEndViewWithAnimation(lblText: GAME_END)
    }
    
    func gameDidEndWithHighscore() {
        addStartEndViewWithAnimation(lblText: YOU_WIN)
        showAlertForHighscoreEntry()
    }
}

// MARK: - Countdown Timer Delegate Methods
extension GameViewController: SRCountdownTimerDelegate {
    
    func timerDidStart(sender: SRCountdownTimer) {
        displayLink = CADisplayLink(target: self, selector: #selector(moveIceberg))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func timerDidPause(sender: SRCountdownTimer) {
         displayLink?.isPaused = true
    }
    
    func timerDidResume(sender: SRCountdownTimer) {
         displayLink?.isPaused = false
    }
    func timerDidReset(sender: SRCountdownTimer) {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        displayLink?.invalidate()
        displayLink = nil
        gamePresenter.timerEnded()
    }
}

// MARK: - Constants
extension GameViewController {
    
    private var durationOfIntersectionAnimation: Double {1.5}
    private var interval: Double {1.0}
    private var beginningValue: Int {20}
    private var reminderCount: Int {10}
}
