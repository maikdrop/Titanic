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
    
    private var crashCount = 0
    private var drivenMiles = 10.0
    private var shipView = UIImageView()
    private var highscoreList = [Player]()
    
    private var game: Titanic! {
        didSet{
            updateViewFromModel()
        }
    }
    private var gameStatus: Titanic.GameStatus = .running {
        didSet {
            switch gameStatus {
            //TODO
            case .running:
                beginStartSequence()
            //game = Titanic(numberOfIcebergs: 10, at: <#T##[Point]#>, with: <#T##[Size]#>)
            case .paused:
                countdownTimer.pause()
                changeTextOfSequenceLabel(to: "Paused")
            case .resumed:
                countdownTimer.resume()
                changeTextOfSequenceLabel(to: "")
            case .canceled:
                countdownTimer.reset()
                changeTextOfSequenceLabel(to: "")
            case .end:
                changeTextOfSequenceLabel(to: "End")
            }
        }
    }
    @IBOutlet weak var knotsLbl: UILabel!

    @IBOutlet weak var milesLbl: UILabel!
    
    @IBOutlet weak var crashCounterLbl: UILabel!
    
    @IBOutlet weak var startSequenceLbl: UILabel!
    
    @IBOutlet weak var popoverMenuBtn: UIBarButtonItem!
    
    @IBAction func showPopoverMenu(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showPopoverMenu", sender: self)
    }
 
    @IBOutlet weak var countdownTimer: SRCountdownTimer!
    
    @IBAction func moveShip(_ sender: UISlider) {
        // Breite des Schiffes
        
        let titanicWidth = Float(shipView.bounds.size.width)
        
        // Breite des Screens
        
        let screenWidth = Float(UIScreen.main.bounds.size.width)
        
        let distance = screenWidth - titanicWidth
        
        shipView.center.x = CGFloat((sender.value) * distance + (titanicWidth/2) )
    
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupShipView()
        countdownTimer.delegate = self
        beginStartSequence()
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
    
    private func updateViewFromModel() {
        
    }
    
    private func resetUI() {
        
    }
    
    private func beginStartSequence()  {
        var startSequenceTime = 5
        self.popoverMenuBtn.isEnabled = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            startSequenceTime -= 1
            if(startSequenceTime == 0){
                self?.startSequenceLbl.text = ""
                startSequenceTime = 5
                timer.invalidate()
                self?.popoverMenuBtn.isEnabled = true
                self?.countdownTimer.start(beginingValue: 5, lastSecondsReminderCount: 10)
            } else if (startSequenceTime == 1) {
                self?.startSequenceLbl.text = "GO"
            } else {
                self?.startSequenceLbl.text = String(startSequenceTime - 1)
            }
        }
    }
    
    private func changeTextOfSequenceLabel(to newText: String) {
        startSequenceLbl.text = newText
    }
    
    private func showAlertForHighscoreEntry(){
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) {_ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.saveHighscoreEntry(with: text)
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
    
    // MARK: HighscoreListFunctions
    private func verifyHighscoreEntry() {
        if highscoreList.count == 10 {
            if let lastPlayerInList = highscoreList.last, lastPlayerInList.drivenMiles < drivenMiles {
                 highscoreList.removeLast()
            }
        }
        showAlertForHighscoreEntry()
    }
    
    private func saveHighscoreEntry(with name: String) {
        highscoreList.append(Player(name: name, drivenMiles: self.drivenMiles))
        highscoreList.sort(by: >)
        let defaults = UserDefaults.standard
        defaults.set(try? PropertyListEncoder().encode(highscoreList), forKey: "Highscorelist")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopoverMenu" {
            if let vc = segue.destination as? MenuTableViewController {
                if let popover = vc.popoverPresentationController {
                    popover.delegate = self
                    vc.delegate = self
                    vc.gameStatus = gameStatus
                }
            }
        }
        if segue.identifier == "showHighscoreList" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.topViewController as? HighscoreListTableViewController {
                    vc.highscoreList = self.highscoreList
                    vc.boldIndex = highscoreList.lastIndex{$0.drivenMiles == drivenMiles}
                }
            }
        }
    }
}

extension GameViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension GameViewController: MenuDelegate {
    
    func changeGameStatus(to newStatus: Titanic.GameStatus) {
        gameStatus = newStatus
    }
}

extension GameViewController: SRCountdownTimerDelegate {
    
    func timerDidStart(sender: SRCountdownTimer) {
    
    }
    
    func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int) {
        
    }
    
    func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval) {
        self.gameStatus = .end
        if let list = HelperFunctions.getHighscoreList(){
            highscoreList = list
            verifyHighscoreEntry()
        }
    }
}
