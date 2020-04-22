//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SRCountdownTimer

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
    var drivenMiles: Double = 0 {
        didSet {
              milesLbl.text = String(format: "Miles: %.2f", drivenMiles)
        }
        
    }
    private var knots: Int {
        50 - crashCount * 5
    }
    private var countdown = 0 {
        didSet {
            popoverMenuBtn.isEnabled = false
            var countdownLabel = createLabel()
            countdownLabel = configureLabel(countdownLabel)
            countdownLabel.text = "\(countdown)"
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if countdownLabel.text == "GO" {
                    countdownLabel.removeFromSuperview()
                    timer.invalidate()
                    self?.countdownTimer.start(beginingValue: 60, interval: 1.0, lastSecondsReminderCount: 10)
                } else {
                     countdownLabel.text = countdownLabel.text == "1" ? "GO": String(Int(countdownLabel.text!)! - 1)
                }
            }
        }
    }
    
    private func createLabel() -> UILabel{
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        gameView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: gameView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: gameView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        return label
    }
    
    private func configureLabel(_ label: UILabel) -> UILabel {
        label.textColor = UIColor.white
        label.text = presenter.gameStatus == .new ? "\(countdown)": presenter.gameStatus?.rawValue
        let font =  UIFont.preferredFont(forTextStyle: .body).withSize(40)
        label.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: font)
        label.adjustsFontForContentSizeCategory = true
        return label
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
    
    @IBOutlet weak var gameView: GameView! {
        didSet {
            gameView.horizontalSlider.addTarget(self, action: #selector(moveShip), for: .valueChanged)
        }
    }
    
    @objc private func moveShip(_ sender: UISlider) {
        let titanicWidth = Float(gameView.ship.bounds.size.width)
        let screenWidth = Float(view.bounds.size.width)
        let distance = screenWidth - titanicWidth
        gameView.ship.center.x = CGFloat((sender.value) * distance + (titanicWidth/2))
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
                    vc.drivenMiles = drivenMiles
                    vc.highscoreList = presenter.highscoreList
                }
            default:
                break
            }
        }
    }
}

extension GameViewController: PresenterGameView {
    
    func updateView(from model: Titanic?) {
        if model == nil {
            pauseView.removeFromSuperview()
            resetGameViewLayout()
            resetTimer()
            crashCount = 0
            drivenMiles = 0
        } else {
            //TODO - Setup View based on Model
              self.countdown = 3
            
        }
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
    
    func showAlert(){
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
            if let userName = alert.textFields?.first?.text, !userName.isEmpty {
                self.presenter.save(of: userName, with: self.drivenMiles)
                self.performSegue(withIdentifier: "showHighscoreList", sender: self)
            }
        }
        doneAction.isEnabled = false
        alert.addAction(doneAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
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
    
    private func resetGameViewLayout() {
        gameView.icebergs.forEach{$0.center.y = 0}
        gameView.ship.center.x = gameView.center.x
        gameView.horizontalSlider.isEnabled = false
        gameView.horizontalSlider.value = 0.5
    }
    
    private func resetTimer() {
        displayLink?.invalidate()
        displayLink = nil
        countdownTimer.reset()
    }
    
    @objc func movingIceberg() {
        print("TEST")
        gameView.icebergs.forEach{$0.center.y += 2}
    }
    
}

extension GameViewController: MenuDelegate,SRCountdownTimerDelegate, UIPopoverPresentationControllerDelegate {
    
    func changeGameStatus(to newStatus: GamePresenter.GameStatus) {
        presenter.gameStatus = newStatus
    }
    
    func timerDidStart(sender: SRCountdownTimer) {
        popoverMenuBtn.isEnabled = true
        gameView.horizontalSlider.isEnabled = true
        displayLink = CADisplayLink(target: self, selector: #selector(movingIceberg))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        self.drivenMiles += self.presenter.calculateDrivenSeaMiles(from: self.knots)
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        presenter.gameStatus = .end
        gameView.horizontalSlider.isEnabled = false
        resetTimer()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
