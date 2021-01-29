/*
 MIT License

 Copyright (c) 2017 Ruslan Serebriakov <rsrbk1@gmail.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// modification for own use:
// 1. modified counterLabel creation and configuration in order to change label
//  size depending on font content size category
// 2. added auto layout for view because of having always constant space between counterlabel and view
// cloned from github: https://github.com/rsrbk/SRCountdownTimer

import UIKit

final class SRCountdownTimer: UIView {

    // MARK: - Properties
    var lineWidth: CGFloat = 2.0
    var lineColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var trailLineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    var isLabelHidden: Bool = false

    var labelFont: UIFont?
    var labelTextColor: UIColor?
    var timerFinishingText: String?

    weak var delegate: SRCountdownTimerDelegate?

    // use minutes and seconds for presentation
    var useMinutesAndSecondsRepresentation = false

    private var lastSecondsReminderCount = 0
    private weak var timer: Timer?
    private lazy var timerBeginningValue: Int = defaultTimerValue
    private lazy var totalTime: TimeInterval = TimeInterval(defaultTimerValue)
    private var elapsedTime: TimeInterval = 0
    private var interval: TimeInterval = 1 // Interval which is set by a user
    private let fireInterval: TimeInterval = 0.01 // ~60 FPS

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = self.labelFont
        label.adjustsFontForContentSizeCategory = true
        addSubview(label)
        return label
    }()

    private (set) var currentCounterValue: Int = 0 {
        didSet {
            if !isLabelHidden {
                if let text = timerFinishingText, currentCounterValue == 0 {
                    counterLabel.text = text
                } else {
                    if useMinutesAndSecondsRepresentation {
                        counterLabel.text = getMinutesAndSeconds(remainingSeconds: currentCounterValue)
                    } else {
                        // MARK: Customization - counterLabelColor and circleLine for the last seconds
                        if currentCounterValue == lastSecondsReminderCount && lastSecondsReminderCount != 0 {
                            setColorOfLabels(to: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
                        }
                        counterLabel.text = getCounterValueAsText()
                    }
                }
            }
            delegate?.timerDidUpdateCounterValue?(sender: self, newValue: currentCounterValue)
        }
    }

    deinit {
        print("DEINIT SRCountdownTimer")
    }
}

// MARK: - Default methods
extension SRCountdownTimer {

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLabel(counterLabel)
        layoutForLabel(counterLabel)
    }

    override func draw(_ rect: CGRect) {

        let context = UIGraphicsGetCurrentContext()
        let radius = (bounds.width - lineWidth) / 2

        var currentAngle: CGFloat!
        let timerBeginningValueInRad = deg2rad(Double((fullAngle/defaultTimerValue) * timerBeginningValue))
        currentAngle = CGFloat(timerBeginningValueInRad * elapsedTime / totalTime)
        let startAngleInRad = CGFloat(deg2rad(Double(getStartAngleInDeg(from: timerBeginningValue))))
        context?.setLineWidth(lineWidth)

        // Main line
        context?.beginPath()
        context?.addArc(
            center: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: startAngleInRad + currentAngle, //- .pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: false)
        context?.setStrokeColor(lineColor.cgColor)
        context?.strokePath()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsLayout()
    }

    override func didMoveToSuperview() {

        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: counterLabel,
            attribute: .height,
            multiplier: 1,
            constant: viewConstraintToCounterLabel))
        addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: counterLabel,
            attribute: .width,
            multiplier: 1,
            constant: viewConstraintToCounterLabel))
    }
}

// MARK: - Public delegate methods
extension SRCountdownTimer {

    /**
     * Starts the timer and the animation. If timer was previously runned, it'll invalidate it.
     * - Parameters:
     *   - beginningValue: Value to start countdown from.
     *   - interval: Interval between reducing the counter(1 second by default)
     */
    func start(beginningValue: Int, interval: TimeInterval = 1, lastSecondsReminderCount: Int = 0) {
        self.timerBeginningValue = beginningValue
        self.interval = interval
        // MARK: - Customization: - color of counterLabel and circleLine will be changed in the last seconds
        self.lastSecondsReminderCount = lastSecondsReminderCount
        totalTime = TimeInterval(beginningValue) * interval
        elapsedTime = 0
        currentCounterValue = beginningValue

        if currentCounterValue <= lastSecondsReminderCount, lastSecondsReminderCount != 0 {
            setColorOfLabels(to: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
        }
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: fireInterval,
            target: self,
            selector: #selector(SRCountdownTimer.timerFired(_:)),
            userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        delegate?.timerDidStart?(sender: self)
    }

    /**
     * Pauses the timer with saving the current state
     */
    func pause() {
        timer?.fireDate = Date.distantFuture
        delegate?.timerDidPause?(sender: self)
    }

    /**
     * Resumes the timer from the current state
     */
   func resume() {
        timer?.fireDate = Date()
        delegate?.timerDidResume?(sender: self)
    }

    /**
     * Reset the timer
     */
    func reset() {
        resetValues()
        elapsedTime = 0
        delegate?.timerDidReset?(sender: self)
        setNeedsDisplay()
        setNeedsLayout()
    }

    /**
     * End the timer
     */
    func end() {
        resetValues()
        delegate?.timerDidEnd?(sender: self, elapsedTime: elapsedTime)
        setNeedsDisplay()
        setNeedsLayout()
    }
}

// MARK: - Private layout methods
private extension SRCountdownTimer {

    /**
     Label configuration
     
     - Parameter label: label to configure
     */
    private func configureLabel(_ label: UILabel) {
        label.text = getCounterValueAsText()
        if let color = self.labelTextColor {
            label.textColor = color
        }
        label.sizeToFit()
    }

    /**
     Label layout
     
     - Parameter label: label to layout
     */
    private func layoutForLabel(_ label: UILabel) {
        label.bounds.size.width = label.bounds.width + counterLabelOffset
        label.bounds.size.height = label.bounds.width
        label.center.x = bounds.width/2
        label.center.y = bounds.height/2
    }

    /**
     Sets the colors of countdown related lables to a new color.
     
     - Parameter newColor: new label color
     */
    private func setColorOfLabels(to newColor: UIColor) {
        lineColor = newColor
        counterLabel.textColor = newColor
        labelTextColor = newColor
    }

    /**
     * Resets the countdown related values to their initial state.
     */
    private func resetValues() {
        setColorOfLabels(to: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        currentCounterValue = 0
        timerBeginningValue = defaultTimerValue
        timer?.invalidate()
    }
}

// MARK: - Private utility methods
private extension SRCountdownTimer {

    /**
     The countdown timer`s target action sets the countdown value.
     
     - Parameter timer: The sending countdown timer.
     */
    @objc private func timerFired(_ timer: Timer) {
        elapsedTime += fireInterval

        if elapsedTime <= totalTime {
            setNeedsDisplay()

            let computedCounterValue = timerBeginningValue - Int(elapsedTime / interval)
            if computedCounterValue != currentCounterValue {
                currentCounterValue = computedCounterValue
            }
        } else {
            end()
        }
    }

    /**
     Converts an angle from degree to rad.
     
     - Parameter angle: angle in degree
     
     - Returns: angle in rad
     */
    private func deg2rad(_ angle: Double) -> Double {
        angle * .pi / 180
    }

    /**
     Converts an angle from rad to degree.
     
     - Parameter angle: angle in rad
     
     - Returns: angle in degree
     */
    private func rad2deg(_ angle: Double) -> Double {
        angle * 180 / .pi
    }

    /**
     Calculates the start angle of the timer`s circle from the beginning timer count.
     
     - Parameter timerCount: The timer`s beginning count.
     
     - Returns: The start angle of the timer`s circle in degree.
     */
    private func getStartAngleInDeg(from timerCount: Int) -> Int {
        let playedGameTime = defaultTimerValue - timerCount
        let playedGameTimeInDeg = playedGameTime * (fullAngle/defaultTimerValue)
        return defaultStartAngle + playedGameTimeInDeg
    }

    /**
     Converts the counter value of the timer into a string.
     
     - Returns: The counter value of the timer as string.
     */
    private func getCounterValueAsText() -> String {
        currentCounterValue < 10 ? "0" + currentCounterValue.description:currentCounterValue.description
    }

    /**
     * Calculate value in minutes and seconds and return it as String
     */
    private func getMinutesAndSeconds(remainingSeconds: Int) -> (String) {
        let minutes = remainingSeconds / defaultTimerValue
        let seconds = remainingSeconds - minutes * defaultTimerValue
        let secondString = seconds < 10 ? "0" + seconds.description : seconds.description
        return minutes.description + ":" + secondString
    }
}

// MARK: - Constants
extension SRCountdownTimer {

    private var viewConstraintToCounterLabel: CGFloat {15}
    private var counterLabelOffset: CGFloat {10}
    private var defaultTimerValue: Int { 60 }
    private var fullAngle: Int { 360 }
    private var defaultStartAngle: Int { -90 }
}
