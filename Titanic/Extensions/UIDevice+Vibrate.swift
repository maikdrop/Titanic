//
//  UIDevice+Vibrate.swift
//  Titanic
//
//  Created by Maik on 29.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit
import AVFoundation

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
