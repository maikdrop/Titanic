//
//  GameViewPresenter+State.swift
//  Titanic
//
//  Created by Maik on 08.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension GameViewPresenter {

    enum GameStatus {
        case new
        case running
        case pause
        case resume
        case end
    }
}

extension GameViewPresenter.GameStatus {

    // MARK: - Create a Game Status
    init?(string: String) {
        switch string {
        case AppStrings.GameStatus.new: self = .new
        case AppStrings.GameStatus.pause: self = .pause
        case AppStrings.GameStatus.resume: self = .resume
        default: return nil
        }
    }

    typealias Status = GameViewPresenter.GameStatus

    // MARK: - Properties
    static var all: [Status] {
        [GameViewPresenter.GameStatus.new, .running, .pause, .resume, .end]
    }

    var stringValue: String {
        switch self {
        case .new: return AppStrings.GameStatus.new
        case .pause: return AppStrings.GameStatus.pause
        case .resume: return AppStrings.GameStatus.resume
        default: return ""
        }
    }

    var list: [GameViewPresenter.GameStatus] {
        switch self {
        case .running: return [.new, .pause]
        case .pause: return [.resume]
        case .end: return [.new]
        default: return []
        }
    }
}
