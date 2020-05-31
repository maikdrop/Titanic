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

import UIKit

@objc public protocol SRCountdownTimerDelegate: class {
    @objc optional func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int)
    @objc optional func timerDidStart(sender: SRCountdownTimer)
    @objc optional func timerDidPause(sender: SRCountdownTimer)
    @objc optional func timerDidResume(sender: SRCountdownTimer)
    @objc optional func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval)
}

public class SRCountdownTimer: UIView {
    public var lineWidth: CGFloat = 2.0
    public var lineColor: UIColor = .white
    public var trailLineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    
    public var isLabelHidden: Bool = false
    public var labelFont: UIFont?
    public var labelTextColor: UIColor?
    public var timerFinishingText: String?

    public weak var delegate: SRCountdownTimerDelegate?
    
    // use minutes and seconds for presentation
    public var useMinutesAndSecondsRepresentation = false
    public var moveClockWise = true
    
    //MARK: Customization - color change of counterLabelColor and circleLineColor for the last seconds
    private var lastSecondsReminderCount = 0

    private weak var timer: Timer?
    private var beginingValue: Int = 1
    private var totalTime: TimeInterval = 1
    private var elapsedTime: TimeInterval = 0
    private var interval: TimeInterval = 1 // Interval which is set by a user
    private let fireInterval: TimeInterval = 0.01 // ~60 FPS

    public lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        return label
    }()
    
    private func configureLabel(_ label: UILabel) {
        label.text = String(currentCounterValue)
        if let color = self.labelTextColor {
            label.textColor = color
        }
        let preferredFont =  UIFont.preferredFont(forTextStyle: .body).withSize(20)
        if #available(iOS 11.0, *) {
            label.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: preferredFont)
        } else {
            label.font = UIFont.systemFont(ofSize: 20)
        }
        label.sizeToFit()
    }
    
    private var currentCounterValue: Int = 0 {
        didSet {
            if !isLabelHidden {
                if let text = timerFinishingText, currentCounterValue == 0 {
                    counterLabel.text = text
                } else {
                    if useMinutesAndSecondsRepresentation {
                        counterLabel.text = getMinutesAndSeconds(remainingSeconds: currentCounterValue)
                    } else {
                        //MARK: Customization - counterLabelColor and circleLine for the last seconds
                        if currentCounterValue == lastSecondsReminderCount && lastSecondsReminderCount != 0 {
                            lineColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                            counterLabel.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                        }
                        counterLabel.text = "\(currentCounterValue)"
                    }
                }
            }

            delegate?.timerDidUpdateCounterValue?(sender: self, newValue: currentCounterValue)
        }
    }

    // MARK: Inits
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        configureLabel(counterLabel)
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("traitCollectionDidChange")
        setNeedsDisplay()
        setNeedsLayout()
    }

    override public func draw(_ rect: CGRect) {

//        print("draw")
        let context = UIGraphicsGetCurrentContext()
        let radius = (bounds.width - lineWidth) / 2

        var currentAngle : CGFloat!

        if moveClockWise {
            currentAngle = CGFloat((.pi * 2 * elapsedTime) / totalTime)
        } else {
            currentAngle = CGFloat(-(.pi * 2 * elapsedTime) / totalTime)
        }

        context?.setLineWidth(lineWidth)

        // Main line
        context?.beginPath()
        context?.addArc(
            center: CGPoint(x: bounds.midX, y:bounds.midY),
            radius: radius,
            startAngle: currentAngle - .pi / 2,
            endAngle: .pi * 2 - .pi / 2,
            clockwise: false)
        context?.setStrokeColor(lineColor.cgColor)
        context?.strokePath()

        // Trail line
        context?.beginPath()
        context?.addArc(
            center: CGPoint(x: bounds.midX, y:bounds.midY),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: currentAngle - .pi / 2,
            clockwise: false)
        context?.setStrokeColor(trailLineColor.cgColor)
        context?.strokePath()
    }

    // MARK: Public methods
    /**
     * Starts the timer and the animation. If timer was previously runned, it'll invalidate it.
     * - Parameters:
     *   - beginingValue: Value to start countdown from.
     *   - interval: Interval between reducing the counter(1 second by default)
     */
    public func start(beginingValue: Int, interval: TimeInterval = 1, lastSecondsReminderCount: Int = 0) {
        self.beginingValue = beginingValue
        self.interval = interval
        //MARK: Customization - color of counterLabel and circleLine will be changed in the last seconds
        self.lastSecondsReminderCount = lastSecondsReminderCount

        totalTime = TimeInterval(beginingValue) * interval
        elapsedTime = 0
        currentCounterValue = beginingValue

        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: fireInterval, target: self, selector: #selector(SRCountdownTimer.timerFired(_:)), userInfo: nil, repeats: true)
//            Timer(timeInterval: fireInterval, target: self, selector: #selector(SRCountdownTimer.timerFired(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
        delegate?.timerDidStart?(sender: self)
    }

    /**
     * Pauses the timer with saving the current state
     */
    public func pause() {
        timer?.fireDate = Date.distantFuture

        delegate?.timerDidPause?(sender: self)
    }

    /**
     * Resumes the timer from the current state
     */
    public func resume() {
        timer?.fireDate = Date()

        delegate?.timerDidResume?(sender: self)
    }

    /**
     * Reset the timer
     */
    public func reset() {
        self.currentCounterValue = 0
    
        //MARK: Customization - counterLabelColor and circleLineColor alyways set to white after Reset
        self.lineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.counterLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
              
        timer?.invalidate()
        self.elapsedTime = 0
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    /**
     * End the timer
     */
    public func end() {
        self.currentCounterValue = 0
        timer?.invalidate()
        
        //MARK: Customization - counterLabelColor and circleLineColor alyways set to white before a new timer starts
        self.counterLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.lineColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        delegate?.timerDidEnd?(sender: self, elapsedTime: elapsedTime)
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    /**
     * Calculate value in minutes and seconds and return it as String
     */
    private func getMinutesAndSeconds(remainingSeconds: Int) -> (String) {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds - minutes * 60
        let secondString = seconds < 10 ? "0" + seconds.description : seconds.description
        return minutes.description + ":" + secondString
    }

    // MARK: Private methods
    @objc private func timerFired(_ timer: Timer) {
        elapsedTime += fireInterval

        if elapsedTime <= totalTime {
            setNeedsDisplay()

            let computedCounterValue = beginingValue - Int(elapsedTime / interval)
            if computedCounterValue != currentCounterValue {
                currentCounterValue = computedCounterValue
            }
        } else {
            end()
        }
    }
    
    private func layout() {
        
    }
}
