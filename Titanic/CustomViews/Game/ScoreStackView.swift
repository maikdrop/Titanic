/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

final class ScoreStackView: UIStackView {

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
