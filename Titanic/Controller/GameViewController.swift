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
    
    private var startSequenceTime = 5
    private var crashCount = 0
    private var drivenMiles = 0.0
    private var shipView = UIImageView()
    
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
        self.popoverMenuBtn.isEnabled = true
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.startSequenceTime -= 1
            if(self?.startSequenceTime == 0){
                self?.startSequenceLbl.text = ""
                self?.startSequenceTime = 5
                timer.invalidate()
                self?.popoverMenuBtn.isEnabled = true
//                self?.highscoreEntry()
                self?.countdownTimer.start(beginingValue: 20, lastSecondsReminderCount: 10)
            } else if (self?.startSequenceTime == 1) {
                self?.startSequenceLbl.text = "GO"
            } else if let remainingSeconds = self?.startSequenceTime {
                self?.startSequenceLbl.text = String(remainingSeconds - 1)
            }
        }
    }
    
    private func changeTextOfSequenceLabel(to newText: String) {
        startSequenceLbl.text = newText
    }
    
    // MARK: HighscoreListFunctions
    private func getHighscoreList() -> [Player]? {
        let defaults = UserDefaults.standard
        guard let highscoreList = defaults.object(forKey: "Highscorelist") as? Data else {
            print("Error getHighscoreList() - Highscorelist is nil")
            return nil
        }
        guard let playerHighscoreList = try? PropertyListDecoder().decode([Player].self, from: highscoreList) else {
            print("Error getHighscoreList() - Decode highscorelist")
            return nil
        }
        return playerHighscoreList
    }
    
    private func verify(highscoreList: [Player]) -> [Player]? {
        if highscoreList.count < 10 {
            print(highscoreList.count)
            return highscoreList
        } else {
            if let lastPlayer = highscoreList.last {
                if drivenMiles <= lastPlayer.drivenMiles {
                    return nil
                } else {
                    var verifiedHighscoreList = highscoreList
                    verifiedHighscoreList.removeLast()
                    return verifiedHighscoreList
                }
            }
        }
        return nil
    }
    
    private func save(highscoreList: [Player]){
        var textFieldText = ""
        let alert = UIAlertController(title: "Name for Highscore", message: "", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default) { test in
            print("Done Tapped")
            if !textFieldText.isEmpty {
                var newHighscoreList = highscoreList
                newHighscoreList.append(Player(name: textFieldText, drivenMiles: self.drivenMiles))
                newHighscoreList.sort(by: >)
                let defaults = UserDefaults.standard
                defaults.set(try? PropertyListEncoder().encode(newHighscoreList), forKey: "Highscorelist")
            }
        }
        doneAction.isEnabled = false
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter your name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) {_ in
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    doneAction.isEnabled = textIsNotEmpty
                    textFieldText = textField.text ?? ""
            }
        })
        alert.addAction(doneAction)
        present(alert, animated: true)
    }
}

extension GameViewController: MenuDelegate {
    
    func changeGameStatus(to newStatus: Titanic.GameStatus) {
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
        self.gameStatus = .end
        if let list = getHighscoreList(), let verifiedList = verify(highscoreList: list) {
            save(highscoreList: verifiedList)
        }
    }
}
