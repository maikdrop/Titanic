//
//  ScoreStackView.swift
//  Titanic
//
//  Created by Maik on 04.05.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ScoreStackView: UIStackView {

     // MARK: - Properties
    private(set) lazy var knotsLbl: UILabel = {
        let knotsLbl = UILabel()
        knotsLbl.text = AppStrings.Game.knotsLblTxt + "0"
        addArrangedSubview(knotsLbl)
        return knotsLbl
    }()

    private(set) lazy var drivenSeaMilesLbl: UILabel = {
        let drivenSeaMilesLbl = UILabel()
        drivenSeaMilesLbl.text = AppStrings.Game.drivenSeaMilesLblTxt + "0.00"
        addArrangedSubview(drivenSeaMilesLbl)
        return drivenSeaMilesLbl
    }()

    private(set) lazy var crashCountLbl: UILabel = {
        let crashCountLbl = UILabel()
        crashCountLbl.text = AppStrings.Game.crashesLblTxt + "0"
        addArrangedSubview(crashCountLbl)
        return crashCountLbl
    }()

    deinit {
           print("DEINIT ScoreStackView")
       }
}

// MARK: - Default Methods
extension ScoreStackView {

    override func didMoveToSuperview() {
        configureScoreLabel(knotsLbl)
        configureScoreLabel(drivenSeaMilesLbl)
        configureScoreLabel(crashCountLbl)
    }
}

// MARK: - Private methods for setting up label layout
private extension ScoreStackView {

    private func configureScoreLabel(_ label: UILabel) {
        label.textColor = .white
        label.font = UIFont().scalableFont(forTextStyle: .title3, fontSize: labelPrefferedFontSize)
        label.adjustsFontForContentSizeCategory = true
    }
}

// MARK: - Constants
extension ScoreStackView {
    private var labelPrefferedFontSize: CGFloat {20}
}
