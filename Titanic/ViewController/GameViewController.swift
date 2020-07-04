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

class GameViewController: UIViewController {
    
    private var gamePresenter: GamePresenter! {
        didSet {
             gamePresenter?.delegate = self
        }
    }
    private var displayLink: CADisplayLink?
    private weak var preparationTimer: Timer?
    private var preparationCountdownForUser = 3 {
        didSet {
            if preparationCountdownForUser == 0 {
                preparationCountdownForUser = 3
            }
        }
    }
    
    private lazy var startEndView = StartEndView(frame: gameView.frame)
    private lazy var pauseView = PauseView(frame: gameView.frame)
    
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
    private var icebergObserver: NSObjectProtocol?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        icebergObserver = NotificationCenter.default.addObserver(
            forName: .ShipDidIntersectWithIceberg,
            object: self.gameView,
            queue: OperationQueue.main,
            using: {[weak self] _ in
                self?.intersectionOfShipAndIcebereg()
        })
        icebergObserver = NotificationCenter.default.addObserver(
            forName: .IcebergDidReachEndOfView,
            object: self.gameView,
            queue: OperationQueue.main,
            using: { [weak self] notification in
                self?.icebergDidReachEndOfViewNotification(notification)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.addSubviews()
        gameView.countdownTimer.delegate = self
        setupGamePresenter()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        preparationTimer?.invalidate()
        gameView.countdownTimer.reset()
        if let observer = icebergObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
     deinit {
        print("DEINIT GameViewController")
    }
    
    //MARK: - GameView View Logic
    
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
    
    private func startPreparationCoutdown() {
        gameControlBtn.isEnabled = false
        if gameView.subviews.contains(startEndView) {
            startEndView.label.text = String(preparationCountdownForUser)
        } else {
              addStartEndView(lblText: String(preparationCountdownForUser))
        }
        //Countdown Timer for user to prepare
        preparationTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(runningPreparationCountdown), userInfo: nil, repeats: true)
    }
    
    @objc private func runningPreparationCountdown() {
        if startEndView.label.text == GO_COUNTDOWN_LBL_TXT {
            removeStartEndView()
            //Countdown Timer for Game
            gameView.countdownTimer.start(beginningValue: beginningValue, interval: interval, lastSecondsReminderCount: reminderCount)
            preparationTimer?.invalidate()
            gameControlBtn.isEnabled = true
        } else {
            preparationCountdownForUser -= 1
           startEndView.label.text = startEndView.label.text == ONE_COUNTDOWN_LBL_TXT ? GO_COUNTDOWN_LBL_TXT : String(preparationCountdownForUser)
            sliderAnimation()
        }
    }
    
    private func sliderAnimation() {
        UIView.transition(
            with: self.gameView.horizontalSlider,
            duration:  self.interval,
            options: [],
            animations: {
                self.lookingForRandomSliderValue()
            }
        )
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
    
    private func intersectionOfShipAndIcebereg() {
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

    private func updateScoreLabels() {
        gameView.scoreStackView.knotsLbl.text = KNOTS_LBL_TEXT + "\(gamePresenter.knots)"
        gameView.scoreStackView.drivenSeaMilesLbl.text = SEA_MILES_LBL_TXT + "\(gamePresenter.drivenSeaMiles)"
        gameView.scoreStackView.crashCountLbl.text = CRASH_COUNT_LBL_TXT + "\(gamePresenter.crashCount)"
    }
    
    private func showAlertForHighscoreEntry() {
        
        let presenter = NewHighscoreEntryPresenter(
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
        )
        presenter.present(in: self)
    }
}

// MARK: - Layout and View Preparation
extension GameViewController {
    
    private func addStartEndView(lblText: String){
        gameView.addSubview(startEndView)
        startEndView.label.text = lblText
        UIView.animate(withDuration: 1) {
            self.startEndView.alpha = 0.8
        }
    }
    
    private func removeStartEndView() {
        UIView.animate(withDuration: 0.5, animations: {
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
        addStartEndView(lblText: GAME_OVER)
    }
    
    func gameDidEndWithoutHighscore() {
        addStartEndView(lblText: GAME_END)
    }
    
    func gameDidEndWithHighscore() {
        addStartEndView(lblText: YOU_WIN)
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
