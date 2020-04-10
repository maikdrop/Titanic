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
    private var shipView = UIImageView()
    private var crashCount = 0 {
        didSet {
            crashCounterLbl.text = "\(crashCount)"
            if crashCount == 4 {
                presenter.gameStatus = .end
            }
        }
    }
    private(set) var drivenMiles = 10.0 {
        didSet {
            milesLbl.text = "\(drivenMiles)"
        }
    }
    private var startSequence = 0 {
        didSet {
            startSequenceLbl.text = startSequence == 0 ? "GO" : "\(startSequence)"
            startSequenceLbl.isHidden = startSequence == -1
        }
    }
    private var knots = 0 {
        didSet {
            knotsLbl.text = "\(knots)"
        }
    }
    
    @IBOutlet private weak var knotsLbl: UILabel!
    @IBOutlet private weak var milesLbl: UILabel!
    @IBOutlet private weak var crashCounterLbl: UILabel!
    @IBOutlet private weak var startSequenceLbl: UILabel!
    @IBOutlet private weak var popoverMenuBtn: UIBarButtonItem!
    @IBOutlet private weak var countdownTimer: SRCountdownTimer!
    
    @IBAction private func showPopoverMenu(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showPopoverMenu", sender: self)
    }

    @IBAction private func moveShip(_ sender: UISlider) {
        let titanicWidth = Float(shipView.bounds.size.width)
        let screenWidth = Float(UIScreen.main.bounds.size.width)
        let distance = screenWidth - titanicWidth
        shipView.center.x = CGFloat((sender.value) * distance + (titanicWidth/2) )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.gameStatus = .new
        countdownTimer.delegate = self
    }
    
    private func setupShipView() {
        let screenWidth = UIScreen.main.bounds.size.width
        let safeAreaHeight = UIApplication.shared.windows[0].safeAreaLayoutGuide.layoutFrame.height
        if let shipImage =  UIImage(named: "ship") {
            shipView = UIImageView(image: shipImage)
            let shipSize = shipImage.size
            shipView.frame = CGRect(x: screenWidth/2 - shipSize.width/2, y: (safeAreaHeight - 185), width: shipSize.width, height: shipSize.height)
            view.addSubview(shipView)
        }
    }
    
    private func beginStartSequence()  {
        popoverMenuBtn.isEnabled = false
        startSequence = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.startSequence -= 1
            if self?.startSequence == -1 {
                self?.popoverMenuBtn.isEnabled = true
                self?.countdownTimer.start(beginingValue: 10, interval: 1.0, lastSecondsReminderCount: 5)
                timer.invalidate()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopoverMenu" {
            if let vc = segue.destination as? MenuTableViewController {
                if let popover = vc.popoverPresentationController {
                    popover.delegate = self
                    vc.delegate = self
                    vc.gameStatus = presenter.gameStatus
                }
            }
        }
        if segue.identifier == "showHighscoreList" {
             if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers.first as? HighscoreListTableViewController {
                    vc.drivenMiles = drivenMiles
                }
                
            }
        }
    }
}

extension GameViewController: PresenterGameView {
   
    func newView() {
        setupShipView()
        beginStartSequence()
    }
    
    func resetView() {
        
    }
    
    func updateView(from: Titanic) {
    
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
}

extension GameViewController: MenuDelegate {
    
    func changeGameStatus(to newStatus: Titanic.GameStatus) {
        presenter.gameStatus = newStatus
    }
}

extension GameViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension GameViewController: SRCountdownTimerDelegate {
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        presenter.gameStatus = .end
    }
}

//func timerDidStart(sender: SRCountdownTimer) {
//
//}
//
//func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
//
//}
