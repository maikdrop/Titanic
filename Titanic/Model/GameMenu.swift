//
//  GameMenu.swift
//  Titanic
//
//  Created by Maik on 06.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

struct GameMenu {
    
    private(set) var menuItems: [String]
    private static var menuDict: [String:GameStatus] = ["New":.running, "Pause":.paused, "Resume":.resumed, "Cancel":.canceled, "End":.end]
    
    init(gameStatus: GameStatus) {
        switch gameStatus {
            case .running, .resumed: menuItems = ["New", "Pause", "Cancel"]
            case .paused: menuItems = ["New", "Resume", "Cancel"]
            case .canceled, .end: menuItems = ["New"]
        }
    }
    
    static func getGameStatus(from menuItem: String) -> GameStatus? {
        return menuDict[menuItem]
    }
}
