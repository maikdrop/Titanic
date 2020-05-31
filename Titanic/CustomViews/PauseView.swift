//
//  PauseView.swift
//  Titanic
//
//  Created by Maik on 20.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class PauseView: UIView {

    private let blurEffect = UIBlurEffect(style: .light)
    private lazy var blurredEffectView = UIVisualEffectView(effect: blurEffect)
    private lazy var vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    private lazy var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
    
    private let statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = "Pause"
        let font =  UIFont.preferredFont(forTextStyle: .body).withSize(50)
        statusLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: font)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        addSubview(blurredEffectView)
        vibrancyEffectView.contentView.addSubview(statusLabel)
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        setupLayout()
    }
    
    private func setupLayout() {
        blurredEffectView.frame = UIApplication.shared.windows[0].safeAreaLayoutGuide.layoutFrame
        vibrancyEffectView.frame = blurredEffectView.frame
        statusLabel.centerXAnchor.constraint(equalTo: blurredEffectView.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: blurredEffectView.centerYAnchor).isActive = true
    }
}
