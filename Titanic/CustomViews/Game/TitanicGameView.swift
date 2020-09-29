/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit
import Combine
import SpriteKit

class TitanicGameView: UIView {

    // MARK: - Properties
    private var icebergsInARow: Int
    private var rowsOfIcebergs: Int

    private var cancellable = [UIView: Cancellable?]()
    private(set) lazy var icebergs = setUpIcebergs()
    private(set) lazy var pauseView = PauseView(frame: frame)
    private(set) var smokeView: SKView? {
        didSet {
            if smokeView != nil {
                addSubview(smokeView!)
            }
        }
    }

    private(set) lazy var ship: ImageView = {
        let shipView = ImageView()
        if let shipImage = UIImage(named: shipImageName) {
            shipView.image = shipImage
            shipView.backgroundColor = .clear
        }
        return shipView
    }()

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

    // MARK: - Create a game view
    init(frame: CGRect, icebergsInARow: Int, rowsOfIcebergs: Int) {
        self.icebergsInARow = icebergsInARow
        self.rowsOfIcebergs = rowsOfIcebergs
        super.init(frame: frame)
        backgroundColor = .oceanBlue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT TitanicGameView")
    }
}

// MARK: - Default methods
extension TitanicGameView {

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let observer = cancellable[subview] {
            observer?.cancel()
        }
        if subview is SmokeView {
           smokeView = nil
        }
    }
}

// MARK: - Public API
extension TitanicGameView {

    /**
     Setup all game view related subviews.
     
     Important: Should be called after game view was loaded because of objects geometry.
     */
    func setupGameView() {
        addSubviews()
        setupLayout()
        setupIcebergPublisher()
    }

    func setSmokeView(at intersectionPoint: CGPoint) {
        smokeView = SmokeView(frame: frame, intersectionPoint: intersectionPoint)
    }
}

 // MARK: - Set up game view and layout of subviews
private extension TitanicGameView {

    /**
     Target action from UISlider when value changed.
     
     - Parameter sender: Sender who is moving the ship
     */
    @objc private func moveShip(by sender: UISlider) {
        let shipWidth = Float(ship.bounds.size.width)
        let screenWidth = Float(bounds.size.width)
        let distance = screenWidth - shipWidth
        ship.center.x = CGFloat((sender.value) * distance + (shipWidth/2))
    }

    /**
     Adding all subviews to Game View.
     */
    private func addSubviews() {
        addSubview(scoreStackView)
        addSubview(gameCountdownTimer)
        addSubview(horizontalSlider)
        addSubview(ship)
        icebergs.forEach {addSubview($0)}
    }

    /**
     Calls functions to setup layout of all subviews.
     */
    private func setupLayout() {
        scoreStackLayout()
        countdownTimerLayout()
        sliderLayout()
        shipLayout()
    }

    /**
     Layout for score labels.
     */
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

    /**
     Layout for countdown timer.
     */
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

    /**
     Layout for slider.
     */
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

    /**
     Layout for ship.
    */
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

    /**
     Create icebergs with initial coordinates.
     */
    private func setUpIcebergs() -> [ImageView] {
        var icebergViewArray = [ImageView]()
        if let width = UIApplication.shared.windows.first?.frame.width {
            let maxIcebergWidth = width / CGFloat(icebergsInARow)
            var horizontalOffset: CGFloat = 0

            for index in 0..<icebergsInARow * rowsOfIcebergs {
                let icebergView = ImageView()
                icebergView.image = UIImage(named: icebergImageName)
                icebergView.backgroundColor = .clear

                let verticalSpaceBetweenIcebergs =
                    icebergView.imageSize.height + icebergVerticalOffset * ship.imageSize.height
                if index.isMultiple(of: icebergsInARow) {horizontalOffset = 0}

                //yCoordinates have to be out of visble y Axis
                icebergView.frame = CGRect(
                    x: maxIcebergWidth/2 - icebergView.imageSize.width/2 + horizontalOffset,
                    y: -(CGFloat(index) * verticalSpaceBetweenIcebergs) - icebergView.imageSize.height,
                    width: icebergView.imageSize.width,
                    height: icebergView.imageSize.height)

                horizontalOffset += maxIcebergWidth
                icebergViewArray.append(icebergView)
            }
            return icebergViewArray
        }
        return icebergViewArray
    }

    /**
     Setting up publishers in order to post Notifications for intersections of ship and iceberg and when an iceberg reached the end of view.
     */
    private func setupIcebergPublisher() {
        icebergs.forEach {icebergView in
            cancellable[icebergView] = icebergView.publisher(for: \.center).sink {[unowned self] _ in
                if icebergView.frame.intersects(self.ship.frame) {
                    var intersectionRect = icebergView.frame.intersection(self.ship.frame)
                    intersectionRect.origin.x += self.ship.frame.width/2
                    NotificationCenter.default.post(name: .ShipDidIntersectWithIceberg,
                                                    object: self,
                                                    userInfo: [AppStrings.UserInfoKey.ship: intersectionRect.origin])
                }
                if icebergView.frame.origin.y > self.frame.height {
                    NotificationCenter.default.post(name: .IcebergReachedEndOfView,
                                                    object: self,
                                                    userInfo: [AppStrings.UserInfoKey.iceberg: icebergView])
                }
            }
        }
    }
}

// MARK: - Constants
extension TitanicGameView {

    private var icebergImageName: String {"iceberg"}
    private var shipImageName: String {"ship"}
    private var icebergVerticalOffset: CGFloat {1.5}
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
}
