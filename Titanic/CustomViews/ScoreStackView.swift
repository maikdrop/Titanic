//
//  ScoreStackView.swift
//  Titanic
//
//  Created by Maik on 04.05.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ScoreStackView: UIStackView {
    
    private(set) lazy var knotsLbl: UILabel = {
        let knotsLbl = UILabel()
        knotsLbl.text = INIT_KNOTS_LBL_TXT
        addArrangedSubview(knotsLbl)
        return knotsLbl
    }()
    
    private(set) lazy var drivenSeaMilesLbl: UILabel = {
        let drivenSeaMilesLbl = UILabel()
        drivenSeaMilesLbl.text = INIT_MILES_LBL_TXT
        addArrangedSubview(drivenSeaMilesLbl)
        return drivenSeaMilesLbl
    }()
    
    private(set) lazy var crashCountLbl: UILabel = {
        let crashCountLbl = UILabel()
        crashCountLbl.text = INIT_CRASH_LBL_TXT
        addArrangedSubview(crashCountLbl)
        return crashCountLbl
    }()

    deinit {
           print("DEINIT ScoreStackView")
       }
    
    override func didMoveToSuperview() {
        configureScoreLabel(knotsLbl)
        configureScoreLabel(drivenSeaMilesLbl)
        configureScoreLabel(crashCountLbl)
    }
    
    private func configureScoreLabel(_ label: UILabel) {
        label.textColor = .white
        label.font = UIFont().scalableFont(forTextStyle: .title3, fontSize: labelPrefferedFontSize)
        label.adjustsFontForContentSizeCategory = true
    }
}

extension ScoreStackView {
    
    private struct SizeRatio {
        static let labelFontSizeToBoundsHeight: CGFloat = 0.03
    }
    private var labelPrefferedFontSize: CGFloat {
        guard let sv = superview else {
            return 20
        }
        return sv.bounds.height * SizeRatio.labelFontSizeToBoundsHeight
    }
}
