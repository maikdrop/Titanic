//
//  GamePickerDelegate.swift
//  Titanic
//
//  Created by Maik on 01.12.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import Combine

class GamePickerDelegate: ObservableObject {

    // MARK: - Properties
    var willChange = PassthroughSubject<GamePickerDelegate, Never>()
    var didChange = PassthroughSubject<GamePickerDelegate, Never>()

    var storedGameDate: Date? {
        willSet {
            willChange.send(self)
        }
        didSet {
            didChange.send(self)
        }
    }
}
