/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Combine

final class GameView: UIView {

    // MARK: - Properties
    private(set) lazy var scoreStackView: ScoreStackView = {
        let scoreStack = ScoreStackView()
        scoreStack.axis = .vertical
        scoreStack.alignment = .fill
        scoreStack.distribution = .fillEqually
        scoreStack.translatesAutoresizingMaskIntoConstraints = false
        return scoreStack
    }()

    private(set) lazy var gameCountdownTimer: SRCountdownTimer = {
        let countdownTimer = SRCountdownTimer()
        countdownTimer.backgroundColor = .clear
        countdownTimer.labelFont = UIFont().scalableFont(forTextStyle: .title3, fontSize: labelPrefferedFontSize)
        countdownTimer.lineColor = .white
        countdownTimer.trailLineColor = .oceanBlue
        countdownTimer.labelTextColor = .white
        countdownTimer.translatesAutoresizingMaskIntoConstraints = false
        return countdownTimer
    }()

    private(set) lazy var horizontalSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = slider.maximumValue/2
        slider.maximumTrackTintColor = UIColor.white
        slider.minimumTrackTintColor = UIColor.white
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(moveShip(by:)), for: .valueChanged)
        return slider
    }()

    private(set) lazy var ship: ImageView =  {
        let shipView = ImageView()
        if let shipImage = UIImage(named: shipImageName) {
            shipView.image = shipImage
            shipView.backgroundColor = .clear
        }
        return shipView
    }()

    private var cancellable = [UIView: Cancellable?]()

    private(set) lazy var icebergs: [ImageView] = {
        var icebergViewArray = [ImageView]()
        if let icebergImage = UIImage(named: icebergImageName) {
            for _ in 0..<icebergsCount {
                let icebergView = ImageView()
                icebergView.image = icebergImage
                icebergView.backgroundColor = .clear
                cancellable[icebergView] = icebergView.publisher(for: \.center).sink { [unowned self] _ in
                    if icebergView.frame.intersects(self.ship.frame) {
                        NotificationCenter.default.post(name: .ShipDidIntersectWithIceberg,
                                                        object: self)
                    }
                    if icebergView.frame.origin.y > self.frame.height {
                        NotificationCenter.default.post(name: .IcebergDidReachEndOfView,
                                                        object: self,
                                                        userInfo: [AppStrings.UserInfoKey.iceberg: icebergView])
                    }
                }
                icebergViewArray.append(icebergView)
            }
        }
        return icebergViewArray
    }()

    deinit {
        print("DEINIT GameView")
    }
}

// MARK: - Default Methods
extension GameView {

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let observer = cancellable[subview] {
            observer?.cancel()
        }
    }
}

// MARK: - Public API to add subviews because icebergs and ship are GameView size related and haven't any constraints
extension GameView {
    func addSubviews() {
        setupView()
        setupLayout()
    }
}

 // MARK: - Private methods for setting up main view and layout of subviews
private extension GameView {

    @objc private func moveShip(by sender: UISlider) {
        let shipWidth = Float(ship.bounds.size.width)
        let screenWidth = Float(bounds.size.width)
        let distance = screenWidth - shipWidth
        ship.center.x = CGFloat((sender.value) * distance + (shipWidth/2))
    }

    private func setupView() {
        addSubview(scoreStackView)
        addSubview(gameCountdownTimer)
        addSubview(horizontalSlider)
        addSubview(ship)
        icebergs.forEach {addSubview($0)}
    }

    private func setupLayout() {
        scoreStackLayout()
        countdownTimerLayout()
        sliderLayout()
        shipLayout()
        icebergLayout()
    }

    private func scoreStackLayout() {
        scoreStackView.leadingAnchor.constraint(
            equalTo: safeAreaLayoutGuide.leadingAnchor,
            constant: subviewConstraintToSuperview)
            .isActive = true
        scoreStackView.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: 0)
            .isActive = true
    }

    private func countdownTimerLayout() {
        gameCountdownTimer.trailingAnchor.constraint(
            equalTo: safeAreaLayoutGuide.trailingAnchor,
            constant: countdownTimerTrailingConstraintToSuperV)
            .isActive = true
        gameCountdownTimer.topAnchor.constraint(
            equalTo: safeAreaLayoutGuide.topAnchor,
            constant: subviewConstraintToSuperview)
            .isActive = true
    }

    private func sliderLayout() {
        horizontalSlider.centerXAnchor.constraint(
            equalTo: centerXAnchor)
            .isActive = true
        horizontalSlider.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: sliderLeadingConstraint)
            .isActive = true
        horizontalSlider.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -sliderBottomConstraint)
            .isActive = true
    }

    private func shipLayout() {
        if let safeAreaHeight = UIApplication.shared.windows.first?.safeAreaLayoutGuide.layoutFrame.height {
            let shipFrameOriginY = safeAreaHeight - shipOffset - ship.imageSize.height
            ship.frame = CGRect(
                x: bounds.width/2 - ship.imageSize.width/2,
                y: shipFrameOriginY,
                width: ship.imageSize.width,
                height: ship.imageSize.height)
        }
    }

    private func icebergLayout() {
        if let first = icebergs.first {
            let icebergHorizontalCount = Int((bounds.width / first.imageSize.width).rounded(.down))
            let widthPerIceberg = bounds.width / CGFloat(icebergHorizontalCount)
            var icebergCenter: CGFloat = 0
            let space = first.imageSize.height + icebergOffset * ship.imageSize.height

            icebergs.enumerated().forEach {iceberg in
                let xCoordinate = icebergCenter - iceberg.element.imageSize.width/2
                //yCoordinates have to be out of visble y Axis
                let yCoordinate = -(CGFloat(iceberg.offset) * space) - iceberg.element.imageSize.height

                if iceberg.offset.isMultiple(of: icebergHorizontalCount) {
                    icebergCenter = widthPerIceberg/2
                }

                iceberg.element.frame = CGRect(
                    x: xCoordinate,
                    y: yCoordinate,
                    width: iceberg.element.imageSize.width,
                    height: iceberg.element.imageSize.height)

                iceberg.element.center.x = icebergCenter
                icebergCenter += widthPerIceberg
            }
        }
    }
}

// MARK: - Constants
extension GameView {

    private var labelPrefferedFontSize: CGFloat {20}
    private var sliderBottomConstraint: CGFloat {25}
    private var sliderLeadingConstraint: CGFloat {20}
    private var subviewConstraintToSuperview: CGFloat {5}
    private var countdownTimerTrailingConstraintToSuperV: CGFloat {-5}
    private var shipOffset: CGFloat {
        if bounds.height > CGFloat(667.0) {
            return 45
        } else {
            return 65
        }
    }
    private var icebergOffset: CGFloat {1.5}
    private var shipImageName: String {"ship"}
    private var icebergImageName: String {"iceberg"}
    private var icebergsCount: Int {6}
}
