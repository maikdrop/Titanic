/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

final class PauseView: UIView {

    // MARK: - Properties
    private let blurEffect = UIBlurEffect(style: .light)
    private lazy var blurredEffectView = UIVisualEffectView(effect: blurEffect)
    private lazy var vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
    private lazy var vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

    private lazy var stateLabel: UILabel = {
        let stateLabel = UILabel()
        stateLabel.text = pause
        stateLabel.font = UIFont().scalableFont(forTextStyle: .title1, fontSize: labelPrefferedFontSize)
        stateLabel.adjustsFontForContentSizeCategory = true
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        return stateLabel
    }()

    // MARK: - Creating a PauseView
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
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

    /**
     Add subviews to view
     */
    private func addSubviews() {
        addSubview(blurredEffectView)
        vibrancyEffectView.contentView.addSubview(stateLabel)
        blurredEffectView.contentView.addSubview(vibrancyEffectView)
        setupLayout()
    }

    /**
     Setup layout of subviews
     */
    private func setupLayout() {
        blurredEffectView.frame = frame
        vibrancyEffectView.frame = blurredEffectView.frame
        stateLabel.centerXAnchor.constraint(equalTo: blurredEffectView.centerXAnchor).isActive = true
        stateLabel.centerYAnchor.constraint(equalTo: blurredEffectView.centerYAnchor).isActive = true
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
