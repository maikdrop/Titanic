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
    
    private lazy var presenter = GamePresenter(view: self)
    private var displayLink: CADisplayLink?
    private var crashCount = 0 {
        didSet {
            gameView.scoreStack.knotsLbl.text = "Knots: " + "\(knots)"
            gameView.scoreStack.crashCountLbl.text = "Crashes: " + "\(crashCount)"
            if crashCount == 5 {
                //TODO call function in presenter: crashCountDidChange(to: crashCount)
                presenter.gameStatus = .end
            }
        }
    }
    private(set) var drivenSeaMiles: Double = 0 {
        didSet {
            gameView.scoreStack.drivenSeaMilesLbl.text = "Miles: " + "\(drivenSeaMiles)"
        }
    }
    private var knots: Int {
        50 - crashCount * 5
    }
    private var countdown = 0 {
        didSet {
            popoverMenuBtn.isEnabled = false
            let countdownLabel = createLabel()
            configureLabel(countdownLabel)
            layoutForLabel(countdownLabel)
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if countdownLabel.text == "GO" {
                    countdownLabel.removeFromSuperview()
                    timer.invalidate()
                    self?.gameView.countdownTimer.start(beginingValue: 20, interval: 1.0, lastSecondsReminderCount: 10)
                } else {
                    countdownLabel.text = countdownLabel.text == "1" ? "GO": String(Int(countdownLabel.text!)! - 1)
                }
            }
        }
    }
    
    @IBOutlet private weak var popoverMenuBtn: UIBarButtonItem!
    @IBOutlet private weak var gameView: GameView! {
        didSet {
            //TODO put in GameView
            gameView.horizontalSlider.addTarget(self, action: #selector(moveShip), for: .valueChanged)
            //TODO put in GameView
            gameView.countdownTimer.delegate = self
            
        }
    }
    //TODO put in GameView
    @objc private func moveShip(_ sender: UISlider) {
        let shipWidth = Float(gameView.ship.bounds.size.width)
        let screenWidth = Float(view.bounds.size.width)
        let distance = screenWidth - shipWidth
        gameView.ship.center.x = CGFloat((sender.value) * distance + (shipWidth/2))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNotificationObserver()
        //TODO put in init of gamePresenter()
        presenter.gameStatus = .new
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetTimer()
    }
    
     deinit {
        print("DEINIT GameViewController")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showPopoverMenu":
                if let vc = segue.destination as? MenuTableViewController, let popover = vc.popoverPresentationController {
                    popover.delegate = self
                    vc.delegate = self
                    //TODO gameStatus should only be a variable
                    vc.gameStatus = presenter.gameStatus
                }
            case "showHighscoreList":
                if let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers.first as? HighscoreListTableViewController {
                    if let playerlist = presenter.playerList {
                        vc.highscoreList = playerlist
                    }
                    vc.drivenMiles = drivenSeaMiles
                    presenter.gameStatus = .canceled
                }
            default:
                break
            }
        }
    }
    
    func setNotificationObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        presenter.gameStatus = .paused
    }
    
    @objc private func moveIceberg() {
        gameView.icebergs.enumerated().forEach{iceberg in
            presenter.moveIcebergAccordingToCrashCount(crashCount)
            //TO DO put in GameView
            //notification for intersection
            if iceberg.element.frame.intersects(gameView.ship.frame) {
                UIDevice.vibrate()
                intersectionAnimation()
                presenter.intersectionOfShipAndIceberg()
                crashCount += 1
            }
        }
    }
    
    private func resetTimer() {
        displayLink?.invalidate()
        displayLink = nil
        gameView.countdownTimer.reset()
    }
}

// layout stuff
extension GameViewController {
    
    private func resetGameViewLayout() {
        gameView.icebergs.forEach{$0.center.y = 0}
        gameView.ship.center.x = gameView.center.x
        gameView.horizontalSlider.isEnabled = false
        gameView.horizontalSlider.value = 0.5
    }
    
    private func resetLabels() {
        crashCount = 0
        drivenSeaMiles = 0
    }
    
    private func createLabel() -> UILabel{
        let label = UILabel()
        gameView.addSubview(label)
        return label
    }
    
    private func configureLabel(_ label: UILabel){
        label.textColor = UIColor.white
        label.text = presenter.gameStatus == .new ? "\(countdown)": presenter.gameStatus?.rawValue
        label.font = UIFont.scalableFont(forTextStyle: .body, fontSize: 40)
        label.adjustsFontForContentSizeCategory = true
    }
    
    private func layoutForLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: gameView.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    private func intersectionAnimation() {
        displayLink?.isPaused = true
        gameView.ship.isHidden = true
        gameView.addSmokeView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            self.gameView.removeSmokeView()
            self.gameView.ship.isHidden = self.presenter.gameStatus == .end
            self.displayLink?.isPaused = self.presenter.gameStatus == .end
        })
    }
}

// presenter delegate methods
extension GameViewController: PresenterGameView {
    
    var mainView: GameView {
        self.gameView
    }
    
    func updateView(from model: Titanic?) {
        if model == nil {
            popoverMenuBtn.isEnabled = true
            gameView.removePauseView()
            resetTimer()
            resetGameViewLayout()
            resetLabels()
        } else {
            model!.icebergs.enumerated().forEach({
                gameView.icebergs[$0.offset].center = CGPoint(x: model!.icebergs[$0.offset].center.x, y:  model!.icebergs[$0.offset].center.y)
            })
        }
    }
    
    func startGame() {
        crashCount = 0
        countdown = 3
    }
    
    //TODO check creation of sperate class for alert
    func showAlertForHighscoreEntry(){
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.presenter.save(of: userName, with: self.drivenSeaMiles)
                self.performSegue(withIdentifier: "showHighscoreList", sender: self)
                self.presenter.gameStatus = .canceled
            }
        }
        doneAction.isEnabled = false
        alert.addAction(doneAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {_ in
            self.presenter.gameStatus = .canceled
        }
        alert.addAction(cancelAction)
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter your name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) {_ in
                let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                let textIsNotEmpty = textCount > 0
                doneAction.isEnabled = textIsNotEmpty
            }
        })
        popoverMenuBtn.isEnabled = false
        present(alert, animated: true)
    }
}

// view delegate methods
extension GameViewController: MenuDelegate, SRCountdownTimerDelegate, UIPopoverPresentationControllerDelegate {
    
    //remove MenuDelegate -> add actionSheet UIAlertController, changeStatus with String
    func changeGameStatus(to newStatus: GamePresenter.GameStatus) {
        presenter.gameStatus = newStatus
    }
    //put delegation methods
    func timerDidPause(sender: SRCountdownTimer) {
        gameView.addPauseView()
        displayLink?.isPaused = true
    }
    
    func timerDidResume(sender: SRCountdownTimer) {
        gameView.removePauseView()
        displayLink?.isPaused = false
    }
    
    func timerDidStart(sender: SRCountdownTimer) {
        popoverMenuBtn.isEnabled = true
        gameView.horizontalSlider.isEnabled = true
        displayLink = CADisplayLink(target: self, selector: #selector(moveIceberg))
        displayLink?.add(to: .current, forMode: .common)
        
       
    }
    
    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        //driven SeaMiles calculated by viewcontroller
        drivenSeaMiles = (drivenSeaMiles + presenter.calculateDrivenSeaMiles(from: knots)).round(to: 2)
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        presenter.gameStatus = .end
        displayLink?.isPaused = true
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
