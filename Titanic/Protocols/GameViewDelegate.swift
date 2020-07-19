//
//  Protocols.swift
//  Titanic
//
//  Created by Maik on 10.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

protocol GameViewDelegate:class {

    func gameDidUpdate()
    func gameDidStart()
    func gameDidPause()
    func gameDidResume()
    func gameDidReset()
    func gameDidEndWithHighscore()
    func gameDidEndWithoutHighscore()
}
