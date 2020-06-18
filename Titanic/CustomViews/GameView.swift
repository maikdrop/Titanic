//
//  GameView.swift
//  Titanic
//
//  Created by Maik on 16.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import SRCountdownTimer

extension Notification.Name {
    static let ShipDidIntersectWithIceberg = Notification.Name("ShipDidIntersectWithIceberg")
    static let IcebergDidReachEndOfView = Notification.Name("IcebergDidReachEndOfView")
}

class GameView: UIView {
    
    private(set) lazy var scoreStackView: ScoreStackView = {
        let scoreStack = ScoreStackView()
        scoreStack.axis = .vertical
        scoreStack.alignment = .fill
        scoreStack.distribution = .fill
        scoreStack.spacing = stackSpacing
        scoreStack.translatesAutoresizingMaskIntoConstraints = false
        return scoreStack
    }()
    
    private(set) lazy var countdownTimer: SRCountdownTimer = {
        let countdownTimer = SRCountdownTimer()
        countdownTimer.backgroundColor = .clear
        countdownTimer.labelFont = UIFont().scalableFont(forTextStyle: .title3, fontSize: labelPrefferedFontSize)
        countdownTimer.lineColor = .white
        countdownTimer.trailLineColor = .oceanBlue
        countdownTimer.labelTextColor = .white
        countdownTimer.translatesAutoresizingMaskIntoConstraints = false
        return countdownTimer
    }()
    
    private(set) lazy var horizontalSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.white
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(moveShip(by:)), for: .valueChanged)
        return slider
    }()
         
    @objc private func moveShip(by sender: UISlider) {
        let shipWidth = Float(ship.bounds.size.width)
        let screenWidth = Float(bounds.size.width)
        let distance = screenWidth - shipWidth
        ship.center.x = CGFloat((sender.value) * distance + (shipWidth/2))
    }
    
    private(set) lazy var ship: ImageView =  {
        let shipView = ImageView()
        if let shipImage = UIImage(named: SHIP_IMAGE_NAME) {
            shipView.image = shipImage
            shipView.backgroundColor = .clear
        }
        return shipView
    }()
    
    private var icebergObservations = [UIView: NSKeyValueObservation]()

    private(set) lazy var icebergs: [ImageView] = {
        var icebergViewArray = [ImageView]()
        var icebergCount = 0
        if let icebergImage = UIImage(named: ICEBERG_IMAGE_NAME) {
            icebergCount = Int((bounds.width / icebergImage.size.width).rounded(.up))
            for index in 0..<icebergCount {
                let icebergView = ImageView()
                icebergView.image = icebergImage
                icebergView.backgroundColor = .clear
                icebergObservations[icebergView] = icebergView.observe(\.center) { [weak self] (iceberg, change) in
                    if iceberg.frame.intersects(self!.ship.frame) {
                        NotificationCenter.default.post(name: .ShipDidIntersectWithIceberg,
                                                        object: self)
                    }
                    if iceberg.frame.origin.y > self!.frame.height {
                        NotificationCenter.default.post(name: .IcebergDidReachEndOfView,
                                                        object: self,
                                                        userInfo: [ICEBERG_VIEW_KEY: iceberg])
                    }
                }
                icebergViewArray.append(icebergView)
            }
        }
        return icebergViewArray
    }()
    
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if icebergObservations[subview] != nil {
            icebergObservations[subview] = nil
        }
    }
    
    deinit {
        print("DEINIT GameView")
    }
    
   // MARK: - public API to add subviews because icebergs and ship are GameView size related and haven't any constraints
    
    func addSubviews() {
       
        setupView()
        setupLayout()
    }
    
    //MARK: - view and layout stuff
    
    private func setupView() {
        addSubview(scoreStackView)
        addSubview(countdownTimer)
        addSubview(horizontalSlider)
        addSubview(ship)
        icebergs.forEach{addSubview($0)}
    }
    
    private func setupLayout() {
        scoreStackLayout()
        countdownTimerLayout()
        sliderLayout()
        shipLayout()
        icebergLayout()
    }
    
    private func scoreStackLayout() {
        scoreStackView.leadingAnchor.constraint(
            equalTo: safeAreaLayoutGuide.leadingAnchor,
            constant: subviewConstraintToSuperview)
            .isActive = true
        scoreStackView.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: subviewConstraintToSuperview)
            .isActive = true
    }
    
    private func countdownTimerLayout() {
        countdownTimer.trailingAnchor.constraint(
            equalTo: safeAreaLayoutGuide.trailingAnchor,
            constant: countdownTimerTrailingConstraintToSuperview)
            .isActive = true
        countdownTimer.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: subviewConstraintToSuperview)
            .isActive = true
    }
    
    private func sliderLayout() {
        horizontalSlider.centerXAnchor.constraint(
            equalTo: centerXAnchor)
            .isActive = true
        horizontalSlider.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: sliderLeadingConstraint)
            .isActive = true
        horizontalSlider.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -sliderBottomConstraint)
            .isActive = true
    }
    
    private func shipLayout() {
        let shipFrameOriginY = bounds.height - sliderBottomConstraint - shipOffset - ship.imageSize.height
        ship.frame = CGRect(
            x: bounds.width/2 - ship.imageSize.width/2,
            y: shipFrameOriginY,
            width: ship.imageSize.width,
            height: ship.imageSize.height)
    }
    
    private func icebergLayout() {
        if let iceberg = icebergs.first {
            let icebergVerticalCount = (bounds.width / iceberg.imageSize.width).rounded(.down)
            let widthPerIceberg = (bounds.width / icebergVerticalCount).rounded()
            var icebergCenter = widthPerIceberg/2
            icebergs.enumerated().forEach{iceberg in
                let x = icebergCenter - iceberg.element.imageSize.width/2
                let y = CGFloat(iceberg.offset) * (iceberg.element.imageSize.height + icebergOffset * ship.imageSize.height)
                
                iceberg.element.frame = CGRect(
                    x: x,
                    y: -y,
                    width: iceberg.element.imageSize.width,
                    height: iceberg.element.imageSize.height)
                
                iceberg.element.center.x = icebergCenter
                if iceberg.element == icebergs.last {
                    let randomIndex = Int.random(in: 0 ..< iceberg.offset)
                    icebergs[iceberg.offset].center.x = icebergs[randomIndex].center.x
                }
                icebergCenter += widthPerIceberg
            }
        }
    }
}

//MARK: - Constants
extension GameView {
    
    private struct SizeRatio {
        static let labelFontSizeToBoundsHeight: CGFloat = 0.03
        static let stackViewSpacingToBoundsHeight: CGFloat = 0.003
    }
    private var labelPrefferedFontSize: CGFloat {
        bounds.height * SizeRatio.labelFontSizeToBoundsHeight
    }
    private var stackSpacing: CGFloat {
        bounds.height * SizeRatio.stackViewSpacingToBoundsHeight
    }
    
    private var sliderBottomConstraint: CGFloat {
        25
    }
    
    private var sliderLeadingConstraint: CGFloat {
        20
    }
    
    private var subviewConstraintToSuperview: CGFloat {
        5
    }
    
    private var countdownTimerTrailingConstraintToSuperview: CGFloat {
        -10
    }
    
    private var shipOffset: CGFloat {
        60
    }
    private var icebergOffset: CGFloat {
        1.5
    }
}
