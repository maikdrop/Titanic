/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import UIKit

final class StartEndView: UIView {

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

    deinit {
        print("DEINIT StartEndView")
    }
}

 // MARK: - Private methods for creating and setting up state label
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
