//
//  PauseView.swift
//  Titanic
//
//  Created by Maik on 04.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class PauseView: UIView {

     // MARK: - Properties
    private let blurEffect = UIBlurEffect(style: .light)
    private lazy var blurredEffectView = UIVisualEffectView(effect: blurEffect)
    private lazy var vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    private lazy var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

    private lazy var statusLabel: UILabel = {
        let statusLabel = UILabel()
        statusLabel.text = pause
        statusLabel.font = UIFont().scalableFont(forTextStyle: .title1, fontSize: labelPrefferedFontSize)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        return statusLabel
    }()

      // MARK: - Creating a PauseView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT PauseView")
    }
}

// MARK: - Private methods for setting up view and layout
private extension PauseView {

    private func setupView() {
        addSubview(blurredEffectView)
        vibrancyEffectView.contentView.addSubview(statusLabel)
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        setupLayout()
    }

    private func setupLayout() {
        blurredEffectView.frame = frame
        vibrancyEffectView.frame = blurredEffectView.frame
        statusLabel.centerXAnchor.constraint(equalTo: blurredEffectView.centerXAnchor).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: blurredEffectView.centerYAnchor).isActive = true
    }
}

// MARK: - Constants
extension PauseView {

    private struct SizeRatio {
        static let labelFontSizeToBoundsHeight: CGFloat = 0.075
    }
    private var labelPrefferedFontSize: CGFloat {
        bounds.height * SizeRatio.labelFontSizeToBoundsHeight
    }
    private var pause: String {"Pause"}
}
