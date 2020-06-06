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
        knotsLbl.text = "Knots: 0"
        addArrangedSubview(knotsLbl)
        return knotsLbl
    }()
    
    private(set) lazy var drivenSeaMilesLbl: UILabel = {
        let drivenSeaMilesLbl = UILabel()
        drivenSeaMilesLbl.text = "Miles: 0.00"
        addArrangedSubview(drivenSeaMilesLbl)
        return drivenSeaMilesLbl
    }()
    
    private(set) lazy var crashCountLbl: UILabel = {
        let crashCountLbl = UILabel()
        crashCountLbl.text = "Crashes: 0"
        addArrangedSubview(crashCountLbl)
        return crashCountLbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureScoreLabel(knotsLbl)
        configureScoreLabel(drivenSeaMilesLbl)
        configureScoreLabel(crashCountLbl)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureScoreLabel(_ label: UILabel) {
        label.textColor = .white
        label.font = UIFont.scalableFont(forTextStyle: .title3, fontSize: 20)
        label.adjustsFontForContentSizeCategory = true
    }
    
    deinit {
        print("DEINIT ScoreStackView")
    }
}
