//
//  SRCountdownTimerDelegate.swift
//  Titanic
//
//  Created by Maik on 10.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

@objc protocol SRCountdownTimerDelegate: class {
    @objc optional func timerDidUpdateCounterValue(sender: SRCountdownTimer, newValue: Int)
    @objc optional func timerDidStart(sender: SRCountdownTimer)
    @objc optional func timerDidPause(sender: SRCountdownTimer)
    @objc optional func timerDidResume(sender: SRCountdownTimer)
    @objc optional func timerDidEnd(sender: SRCountdownTimer, elapsedTime: TimeInterval)
    @objc optional func timerDidReset(sender: SRCountdownTimer)
}
