//
//  GameView.swift
//  Titanic
//
//  Created by Maik on 16.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SRCountdownTimer

class GameView: UIView {
    
    private (set) lazy var scoreStack: ScoreStackView = {
        let scoreStack = ScoreStackView()
        scoreStack.axis = .vertical
        scoreStack.alignment = .fill
        scoreStack.distribution = .fill
        scoreStack.spacing = 7.0
        scoreStack.translatesAutoresizingMaskIntoConstraints = false
        return scoreStack
    }()
    
    private(set) lazy var countdownTimer: SRCountdownTimer = {
        let countdownTimer = SRCountdownTimer()
        countdownTimer.backgroundColor = .clear
        countdownTimer.labelFont = UIFont.scalableFont(forTextStyle: .title3, fontSize: 20)
        countdownTimer.lineColor = .white
        countdownTimer.trailLineColor = .oceanBlue
        countdownTimer.labelTextColor = .white
        countdownTimer.translatesAutoresizingMaskIntoConstraints = false
        return countdownTimer
    }()
    
    private(set) lazy var horizontalSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.tintColor = UIColor.white
        slider.isEnabled = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private(set) lazy var ship: ShipView =  {
        let shipView = ShipView()
        shipView.backgroundColor = .clear
        return shipView
    }()
    
    private(set) lazy var icebergs: [IcebergView] = {
        var icebergViewArray = [IcebergView]()
        let icebergCount = Int((ScreenSize.currentDevice.width / IcebergView().imageSize.width).rounded())
        for index in 0..<icebergCount {
            let icebergView = IcebergView()
            icebergView.backgroundColor = .clear
            icebergViewArray.append(icebergView)
        }
        return icebergViewArray
    }()
    
    private lazy var pauseView = PauseView()
    
    private let sliderBottomConstraint: CGFloat = 25
    private let sliderLeadingConstraint: CGFloat = 20
    private let space: CGFloat = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func addPauseView() {
        self.addSubview(pauseView)
        ship.isHidden = true
        icebergs.forEach{$0.isHidden = true}
    }
    
    func removePauseView() {
        pauseView.removeFromSuperview()
        ship.isHidden = false
        icebergs.forEach{$0.isHidden = false}
    }
    
    private func setupView() {
        addSubview(scoreStack)
        addSubview(countdownTimer)
        addSubview(horizontalSlider)
        addSubview(ship)
        icebergs.forEach{addSubview($0)}
        setupLayout()
    }
    
    private func setupLayout() {
        scoreStackLayout()
        countdownTimerLayout()
        sliderLayout()
        shipLayout()
        icebergLayout()
    }
    
    private func scoreStackLayout() {
        scoreStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5).isActive = true
        scoreStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    }
    
    private func countdownTimerLayout() {
        
        countdownTimer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
        countdownTimer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        
        addConstraint(NSLayoutConstraint(item: countdownTimer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: countdownTimer.counterLabel, attribute: .height, multiplier: 1, constant: 20))
        addConstraint(NSLayoutConstraint(item: countdownTimer, attribute: .width, relatedBy: .greaterThanOrEqual, toItem:  countdownTimer.counterLabel, attribute: .width, multiplier: 1, constant: 20))
    }
    
    private func sliderLayout() {
        horizontalSlider.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        horizontalSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sliderLeadingConstraint).isActive = true
        horizontalSlider.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -sliderBottomConstraint).isActive = true
    }
    
    private func shipLayout() {
        let safeAreaMaxY = UIApplication.shared.windows[0].safeAreaLayoutGuide.layoutFrame.maxY
        let yCoordinateOfShip = safeAreaMaxY - sliderBottomConstraint - space - ship.imageSize.height
        ship.frame = CGRect(x: bounds.width/2 - ship.imageSize.width/2, y: yCoordinateOfShip, width: ship.imageSize.width, height: ship.imageSize.height)
        //         print(ship.frame)
    }
    
    private func icebergLayout() {
        let width = (UIScreen.main.bounds.size.width / CGFloat(icebergs.count)).rounded()
        var center = width / 2
        icebergs.enumerated().forEach{iceberg in
            iceberg.element.frame = CGRect(x: 0, y: 0, width: iceberg.element.imageSize.width, height: iceberg.element.imageSize.height)
            iceberg.element.center = CGPoint(x: center, y: 0)
            center += width
        }
    }
}

extension GameView {
    struct ScreenSize {
        static let currentDevice = UIScreen.main.bounds.size
        static let iphoneSE = CGSize(width: 320, height: 568)
    }
}

extension UIColor {
    static let oceanBlue = UIColor.init(red: 0, green: 0.328521, blue: 0.574885, alpha: 1)
}
