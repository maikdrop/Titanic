//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import AVFoundation
import SRCountdownTimer
import SpriteKit

class GameViewController: UIViewController {
    
    private lazy var presenter = GamePresenter(view: self)
    private var displayLink: CADisplayLink?
    private var pauseView = PauseView()
    private var crashCount = 0 {
        didSet {
            gameView.scoreStack.knotsLbl.text = "Knots: " + "\(knots)"
            gameView.scoreStack.crashCountLbl.text = "Crashes: " + "\(crashCount)"
            if crashCount == 5 {
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
                    self?.gameView.countdownTimer.start(beginingValue: 5, interval: 1.0, lastSecondsReminderCount: 10)
                } else {
                    countdownLabel.text = countdownLabel.text == "1" ? "GO": String(Int(countdownLabel.text!)! - 1)
                }
            }
        }
    }

    @IBOutlet private weak var popoverMenuBtn: UIBarButtonItem!
    @IBOutlet private weak var gameView: GameView! {
        didSet {
            gameView.horizontalSlider.addTarget(self, action: #selector(moveShip), for: .valueChanged)
            gameView.countdownTimer.delegate = self
          
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.gameStatus = .new
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showPopoverMenu":
                if let vc = segue.destination as? MenuTableViewController, let popover = vc.popoverPresentationController {
                    popover.delegate = self
                    vc.delegate = self
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
    
    @objc private func moveShip(_ sender: UISlider) {
        let shipWidth = Float(gameView.ship.bounds.size.width)
        let screenWidth = Float(view.bounds.size.width)
        let distance = screenWidth - shipWidth
        gameView.ship.center.x = CGFloat((sender.value) * distance + (shipWidth/2))
    }
    
    @objc private func moveIceberg() {
        gameView.icebergs.enumerated().forEach{iceberg in
            presenter.moveIcebergAccordingToCrashCount(crashCount)
            if iceberg.element.frame.intersects(gameView.ship.frame) {
                crashCount += 1
                UIDevice.vibrate()
                intersectionAnimation()
                presenter.intersectionWithIceberg(at: iceberg.offset)
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
        let skView = SmokeView(frame: gameView.frame)
        gameView.addSubview(skView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
            skView.removeFromSuperview()
            self.gameView.ship.isHidden = false
            self.displayLink?.isPaused = false
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
            pauseView.removeFromSuperview()
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
    
    func pauseGame() {
        gameView.addSubview(pauseView)
        gameView.countdownTimer.pause()
        displayLink?.isPaused = true
    }
    
    func resumeGame() {
        pauseView.removeFromSuperview()
        gameView.countdownTimer.resume()
        displayLink?.isPaused = false
    }
    
    //TODO check creation of sperate class for alert
    func showAlertForHighscoreEntry(){
        let drivenMiles = self.drivenSeaMiles
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.presenter.save(of: userName, with: drivenMiles)
                self.performSegue(withIdentifier: "showHighscoreList", sender: self)
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
        present(alert, animated: true)
    }
}

// view delegate methods
extension GameViewController: MenuDelegate, SRCountdownTimerDelegate, UIPopoverPresentationControllerDelegate {
    
    func changeGameStatus(to newStatus: GamePresenter.GameStatus) {
        presenter.gameStatus = newStatus
    }
    
    func timerDidStart(sender: SRCountdownTimer) {
        popoverMenuBtn.isEnabled = true
        gameView.horizontalSlider.isEnabled = true
        displayLink = CADisplayLink(target: self, selector: #selector(moveIceberg))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        drivenSeaMiles = (drivenSeaMiles + presenter.calculateDrivenSeaMiles(from: knots)).round(to: 2)
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        presenter.gameStatus = .end
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
