//
//  StartUpView.swift
//  Titanic
//
//  Created by Maik on 30.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class StartEndView: UIView {

     // MARK: - Properties
    private(set) lazy var label: UILabel = {
        let label = createLabel()
        configureLabel(label)
        layoutForLabel(label)
        return label
    }()

    // MARK: - Creating a StartEndView
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        isOpaque = false
        addSubview(label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

 // MARK: - Private methods for creating and setting up status label
private extension StartEndView {

    private func createLabel() -> UILabel {
        let label = UILabel()
        addSubview(label)
        return label
    }

    private func configureLabel(_ label: UILabel) {
        label.textColor = .label
        label.numberOfLines = 0
        label.font = UIFont().scalableFont(forTextStyle: .body, fontSize: labelPrefferedFontSize)
        label.adjustsFontForContentSizeCategory = true
    }

    private func layoutForLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
        label.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}

// MARK: - Constants
extension StartEndView {

    private struct SizeRatio {
        static let labelFontSizeToBoundsHeight: CGFloat = 0.06
    }

    private var labelPrefferedFontSize: CGFloat {
        return bounds.height * SizeRatio.labelFontSizeToBoundsHeight
    }
}
