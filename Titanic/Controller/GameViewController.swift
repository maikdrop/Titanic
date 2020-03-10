//
//  GameViewController.swift
//  Titanic
//
//  Created by Maik on 24.02.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SRCountdownTimer

enum GameStatus {
    case running
    case paused
    case resumed
    case canceled
}

class GameViewController: UIViewController {
    
    private var startSequenceTime = 5
    private var gameStatus: GameStatus = .running {
        didSet {
            switch gameStatus {
            //TODO
            case .running:
                print("running")
                beginStartSequence()
            //game = Titanic(numberOfIcebergs: 10, at: <#T##[Point]#>, with: <#T##[Size]#>)
            case .paused: print("paused")
            //timer.stop()
            case .resumed: print("resumed")
            //timer.play()
            case .canceled: print("canceled")
                //invalidate timers
                //resetGame
            }
        }
    }
    
    @IBOutlet weak var knotsLbl: UILabel!
    
    @IBOutlet weak var milesLbl: UILabel!
    
    @IBOutlet weak var crashCounterLbl: UILabel!
    
    @IBOutlet weak var startSequenceLbl: UILabel!
    
    @IBAction func showPopoverMenu(_ sender: UIBarButtonItem) {
        let storyboard : UIStoryboard = UIStoryboard(name: MAIN, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: MENU_TABLE_VIEW_CONTROLLER) as? MenuTableViewController {
            vc.delegate = self
            vc.gameStatus = gameStatus
            vc.modalPresentationStyle = .popover
            if let popover = vc.popoverPresentationController {
                popover.delegate = self
                popover.permittedArrowDirections = [.up]
                popover.barButtonItem = sender
                present(vc, animated: true)
            }
        }
        
    }
    
    
    @IBOutlet weak var countdownTimerLabl: SRCountdownTimer!
    
    
    
    private var game: Titanic! {
        didSet{
            updateViewFromModel()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdownTimerLabl.delegate = self
        beginStartSequence()
        
        //TODO
        setupIcebergs()
        //
    }
    
    private func setupIcebergs() {
        
    }
    
    private func updateViewFromModel() {
        
    }
    
    private func resetGame() {
        
    }
    
    func beginStartSequence()  {
        startSequenceLbl.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.startSequenceTime -= 1
            if(self?.startSequenceTime == 0){
                self?.startSequenceLbl.isHidden = true
                self?.startSequenceLbl.text = ""
                self?.startSequenceTime = 5
                timer.invalidate()
                self?.countdownTimerLabl.start(beginingValue: 20, lastSecondsReminderCount: 10)
            } else if (self?.startSequenceTime == 1) {
                self?.startSequenceLbl.text = "GO"
            } else if let remainingSeconds = self?.startSequenceTime {
                self?.startSequenceLbl.text = String(remainingSeconds - 1)
            }
        }
    }
}

extension GameViewController: MenuDelegate {
    
    func changeGameStatus(to newStatus: GameStatus) {
        gameStatus = newStatus
    }
}

extension GameViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        return .none
    }
}

extension GameViewController: SRCountdownTimerDelegate {
    
    func timerDidStart(sender: SRCountdownTimer) {
    }
    
    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        
    }
}
