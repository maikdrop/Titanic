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
    
    private lazy var label: UILabel = {
        let label = createLabel()
        configureLabel(label)
        layoutForLabel(label)
        return label
    }()
        
    @IBOutlet private weak var gameControlBtn: UIBarButtonItem!
    @IBAction func changeGameStatus(_ sender: UIBarButtonItem) {
        let alert = UIAlertController (title: ACTION_TITLE, message: "", preferredStyle: .actionSheet)
        gamePresenter.gameStatus?.menuList.forEach({status in
                let style = status == .reset ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
                alert.addAction(UIAlertAction(title: status.rawValue, style: style) {_ in
                //TODO check because of retain memory cycle
                    self.gamePresenter.changeGameStatus(to: status)
            })
        })
        alert.addAction(UIAlertAction(title: ACTION_TITLE_CANCEL_ACTION, style: .cancel) {_ in})
        present(alert, animated: true)
    }
    
    @IBOutlet private weak var gameView: GameView!
    
    @IBAction func goBackToResumeGame(segue: UIStoryboardSegue) {
        if let mvcUnwoundFrom = segue.source as? PauseViewController {
             gamePresenter.changeGameStatus(to: mvcUnwoundFrom.gameStatus)
        }
    }
    
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
        gameView.countdownTimer.reset()
        if let observer = icebergObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
     deinit {
        print("DEINIT GameViewController")
    }
    
    //MARK: - GameView Logic
    
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
    
    private func startCountdown() {
        var countdown = countdownForTimer
        label.text = String(countdown)
        gameControlBtn.isEnabled = false
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {timer in
            if self.label.text == GO_COUNTDOWN_LBL_TXT {
                self.label.text = ""
                timer.invalidate()
                self.gameView.countdownTimer.start(beginningValue: self.countdownTimerbeginningValue, interval: self.interval, lastSecondsReminderCount: self.reminderCount)
            } else {
                countdown -= 1
                self.label.text = self.label.text == ONE_COUNTDOWN_LBL_TXT ? GO_COUNTDOWN_LBL_TXT: String(countdown)
                UIView.transition(
                    with: self.gameView.horizontalSlider,
                    duration:  self.interval,
                    options: [],
                    animations: {
                        var newSliderValue:Float = 0
                        if self.label.text == GO_COUNTDOWN_LBL_TXT {
                            newSliderValue = self.gameView.horizontalSlider.maximumValue/2 
                        } else {
                            newSliderValue = self.gameView.horizontalSlider.value == 1 ? 0:1
                            print("NEW Slider Value")
                            print(newSliderValue)
                        }
                        self.gameView.horizontalSlider.setValue(newSliderValue, animated: true)
                        self.gameView.horizontalSlider.sendActions(for: .valueChanged)
                    }
                )
            }
        }
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
        let alert = UIAlertController(title: ALERT_TITLE, message: ALERT_MESSAGE, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: ALERT_TITLE_DONE_ACTION, style: .default) {_ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.gamePresenter.nameForHighscoreEntry(userName: userName)
                self.performSegue(withIdentifier: SHOW_HIGHSCORE_LIST, sender: self)
            }
        })
        alert.actions.first?.isEnabled = false
        
        alert.addAction(UIAlertAction(title: ALERT_TITLE_CANCEL_ACTION, style: .cancel) {_ in
            
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = ALERT_TEXT_FIELD_PLCHOLDER
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) {_ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                alert.actions.first?.isEnabled = textIsNotEmpty
            }
        })
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SHOW_HIGHSCORE_LIST {
            if let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? HighscoreListTableViewController {
                if let playerlist = gamePresenter.highscoreList {
                    vc.highscoreList = playerlist
                }
                vc.drivenSeaMiles = gamePresenter.drivenSeaMiles
            }
        }
    }
}

// MARK: - Layout and View Preparation
extension GameViewController {
    
    private func setupSlider() {
        gameView.horizontalSlider.value = gameView.horizontalSlider.minimumValue
        gameView.horizontalSlider.sendActions(for: .valueChanged)
    }
    private func createLabel() -> UILabel{
        let label = UILabel()
        gameView.addSubview(label)
        return label
    }
    
    private func configureLabel(_ label: UILabel){
        label.textColor = UIColor.white
        label.font = UIFont().scalableFont(forTextStyle: .body, fontSize: labelPrefferedFontSize)
        label.adjustsFontForContentSizeCategory = true
    }
    
    private func layoutForLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: gameView.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
}

// MARK: - Presenter Delegate Methods
extension GameViewController: GamePresenterDelegate {
    
    func gameDidUpdate() {
        updateViewFromModel()
        updateScoreLabels()
    }
    
    func gameDidStart() {
        setupSlider()
        startCountdown()
    }
    
    func gameDidPause() {
        gameView.countdownTimer.pause()
        self.performSegue(withIdentifier: SHOW_PAUSE_VIEW, sender: self)
    }
    
    func gameDidResume() {
        gameView.countdownTimer.resume()
    }
    
    func gameDidReset() {
        gameView.countdownTimer.reset()
        label.text = GAME_OVER
    }
    
    func gameDidEndWithoutHighscore() {
        label.text = GAME_END
    }
    
    func gameDidEndWithHighscore() {
        label.text = YOU_WIN
        showAlertForHighscoreEntry()
    }
}

// MARK: - Countdown Timer Delegate Methods
extension GameViewController: SRCountdownTimerDelegate {
    
    func timerDidStart(sender: SRCountdownTimer) {
        gameControlBtn.isEnabled = true
        displayLink = CADisplayLink(target: self, selector: #selector(moveIceberg))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func timerDidPause(sender: SRCountdownTimer) {
         displayLink?.isPaused = true
    }
    
    func timerDidResume(sender: SRCountdownTimer) {
         displayLink?.isPaused = false
    }

    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        displayLink?.invalidate()
        displayLink = nil
        gamePresenter.timerEnded()
    }
    
    func timerDidReset(sender: SRCountdownTimer) {
        displayLink?.invalidate()
        displayLink = nil
    }
}

// MARK: - Constants
extension GameViewController {
    
    private struct SizeRatio {
        static let labelFontSizeToBoundsHeight: CGFloat = 0.06
    }
    private var labelPrefferedFontSize: CGFloat {
        return gameView.bounds.height * SizeRatio.labelFontSizeToBoundsHeight
    }
    
    private var durationOfIntersectionAnimation: Double {
           1.5
    }
    
    private var countdownForTimer: Int {
        3
    }
    
    private var interval: Double {
        1.0
    }
    
    private var countdownTimerbeginningValue: Int {
        20
    }
    
    private var reminderCount: Int {
        10
    }
    
}


//    func setNotificationObserver() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
//    }
//
//    @objc func appMovedToBackground() {
//        presenter.gameStatus = .pause
//    }
