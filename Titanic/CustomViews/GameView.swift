//
//  GameView.swift
//  Titanic
//
//  Created by Maik on 16.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class GameView: UIView {
    
    private(set) lazy var horizontalSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.tintColor = UIColor.white
        slider.isEnabled = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private(set) lazy var ship: ShipView =  {
        let imageView = ShipView()
        return imageView
    }()
    
    private(set) var icebergs: [IcebergView] = {
        var array = [IcebergView]()
        for index in 0...2 {
            let iceberg = IcebergView()
            array.append(iceberg)
        }
        return array
    }()
    
    private let sliderBottomConstraint: CGFloat = 25
    private let sliderLeadingConstraint: CGFloat = 20
    private let space: CGFloat = 60
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func didAddSubview(_ subview: UIView) {
        if subview is PauseView {
            ship.isHidden = true
            icebergs.forEach{$0.isHidden = true}
        }
    }
    
    override func willRemoveSubview(_ subview: UIView) {
        if subview is PauseView {
            ship.isHidden = false
            icebergs.forEach{$0.isHidden = false}
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(horizontalSlider)
        addSubview(ship)
        icebergs.forEach{addSubview($0)}
        setupLayout()
    }
    
    private func setupLayout() {
        sliderLayout()
        shipLayout()
        icebergLayout()
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
    }
    
    private func icebergLayout() {
        var xPositions = [CGFloat]()
        if let iceberg = icebergs.first {
            xPositions = [bounds.minX, bounds.width/2 - iceberg.imageSize.width/2, bounds.maxX - iceberg.imageSize.width]
        }
        icebergs.enumerated().forEach{iceberg in
            iceberg.element.frame = CGRect(x: xPositions[iceberg.offset], y: 0, width: iceberg.element.imageSize.width, height: iceberg.element.imageSize.height)
        }
    }
}

extension GameView {
    struct ScreenSize {
        static let currentDevice = UIScreen.main.bounds.size
        static let iphoneSE = CGSize(width: 320, height: 568)
    }
}
