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
            knotsLbl.text = "Knots: " + "\(knots)"
            crashCounterLbl.text = "Crashes: " + "\(crashCount)"
            if crashCount == 5 {
                presenter.gameStatus = .end
            }
        }
    }
    private var drivenMiles: Double = 0 {
        didSet {
             milesLbl.text = "Miles: " + "\(drivenMiles)"
        }
    }
    private var knots: Int {
        50 - crashCount * 5
    }
    private var countdown = 0 {
        didSet {
            popoverMenuBtn.isEnabled = false
            var countdownLabel = createLabel()
            countdownLabel = configureCountdownLabel(countdownLabel)
            countdownLabel.text = "\(countdown)"
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if countdownLabel.text == "GO" {
                    countdownLabel.removeFromSuperview()
                    timer.invalidate()
                    self?.countdownTimer.start(beginingValue: 5, interval: 1.0, lastSecondsReminderCount: 10)
                } else {
                    countdownLabel.text = countdownLabel.text == "1" ? "GO": String(Int(countdownLabel.text!)! - 1)
                }
            }
        }
    }
    
    @IBOutlet private weak var knotsLbl: UILabel! {
        didSet {
            knotsLbl.text = "Knots: " + "\(knots)"
        }
    }
    @IBOutlet private weak var milesLbl: UILabel! {
        didSet {
            milesLbl.text = String(format: "Miles: %.2f", drivenMiles)
        }
    }
    @IBOutlet private weak var crashCounterLbl: UILabel! {
        didSet {
            crashCounterLbl.text = "Crashes: " + "\(crashCount)"
        }
    }
    @IBOutlet private weak var popoverMenuBtn: UIBarButtonItem!
    @IBOutlet private weak var countdownTimer: SRCountdownTimer! {
        didSet {
            countdownTimer.delegate = self
            countdownTimer.labelFont = UIFont.systemFont(ofSize: 20)
        }
    }
    
    @IBOutlet private weak var gameView: GameView! {
        didSet {
            gameView.horizontalSlider.addTarget(self, action: #selector(moveShip), for: .valueChanged)
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
                    vc.drivenMiles = drivenMiles
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
                UIDevice.vibrate()
                intersectionAnimation()
                presenter.intersectionWithIceberg(at: iceberg.offset)
            }
            
        }
    }
    
    private func resetTimer() {
        displayLink?.invalidate()
        displayLink = nil
        countdownTimer.reset()
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
        drivenMiles = 0
    }
    
    private func createLabel() -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: gameView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        return label
    }
    
    private func configureCountdownLabel(_ label: UILabel) -> UILabel {
        label.textColor = UIColor.white
        label.text = presenter.gameStatus == .new ? "\(countdown)": presenter.gameStatus?.rawValue
        let font =  UIFont.preferredFont(forTextStyle: .body).withSize(40)
        label.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        return label
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
        self.countdown = 3
    }
    
    func pauseGame() {
        gameView.addSubview(pauseView)
        countdownTimer.pause()
        displayLink?.isPaused = true
    }
    
    func resumeGame() {
        pauseView.removeFromSuperview()
        countdownTimer.resume()
        displayLink?.isPaused = false
    }
    
    func showAlertForHighscoreEntry(){
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.presenter.save(of: userName, with: self.drivenMiles)
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
        drivenMiles = (drivenMiles + presenter.calculateDrivenSeaMiles(from: knots)).round(to: 2)
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
