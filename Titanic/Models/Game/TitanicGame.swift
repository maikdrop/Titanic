//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

final class TitanicGame {

    // MARK: - Properties
    private var icebergInitXOrigin = [Double]()
    private var icebergInitYOrigin = [Double]()
    private(set) var icebergs = [Iceberg]()

    private var distanceBetweenIcebergs = 0.0
    private(set) var drivenSeaMiles = 0.0

    private var seaMilesPerSecond: Double {
        (Double(knots) / 60)/60
    }
    var knots: Int {
        startKnots - crashCount * knotsReducer
    }

    private(set) var crashCount = 0 {
        didSet {
            if crashCount == maximumCrashs {
                 NotificationCenter.default.post(name: .GameDidEnd, object: self)
            }
        }
    }
    private(set) var countdown = 0 {
        didSet {
            if countdown == 0 {
                  NotificationCenter.default.post(name: .GameDidEnd, object: self)
            }

        }
    }

     // MARK: - Creating a Titanic Game
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: [(width: Double, height: Double)]) {
        self.icebergInitXOrigin = icebergInitXOrigin
        self.icebergInitYOrigin = icebergInitYOrigin
        for index in 0..<icebergInitXOrigin.count {
            let origin = Iceberg.Point(
                xCoordinate: icebergInitXOrigin[index],
                yCoordinate: icebergInitYOrigin[index])
            let size = Iceberg.Size(width: icebergSize[index].width, height: icebergSize[index].height)
            let iceberg = Iceberg(origin: origin, size: size)
            icebergs += [iceberg]
        }
        distanceBetweenIcebergs = calculateDistanceBetweenIcebergs()
    }

    deinit {
        print("DEINIT Titanic")
    }
}

  // MARK: - Public API to control a Titanic Game
extension TitanicGame {

    func moveIcebergsVertically() {
        drivenSeaMiles += seaMilesPerSecond
        drivenSeaMiles = drivenSeaMiles.round(to: 2)
        for index in 0..<icebergs.count {
            icebergs[index].center.yCoordinate += moveFactor - Double(crashCount)/2
        }
    }

    func resetIceberg(at index: Int) {
        if let icebergWithSmallestY = icebergs.min() {
            icebergs[index].origin.yCoordinate = icebergWithSmallestY.origin.yCoordinate - distanceBetweenIcebergs
        }
    }

    func collisionBetweenShipAndIceberg() {
        crashCount += 1
        shuffleIcebergs()
    }

    func countdownUpdate() {
        countdown -= 1
    }

    func startNewRound() {
        drivenSeaMiles = 0.0
        crashCount = 0
        countdown = countdownBeginningValue
        shuffleIcebergs()
    }

}

// MARK: - Private methods to customize the behavior of a Titanic Game
private extension TitanicGame {

    private func calculateDistanceBetweenIcebergs() -> Double {
        if icebergs.count > 1 {
            return abs(icebergs[0].origin.yCoordinate.distance(to: icebergs[1].origin.yCoordinate))
        }
        return 0
    }

    private func shuffleIcebergs() {
        shuffleIcebergVertically(at: Array(icebergs.indices))
        shuffleIcebergHorizontally(at: Array(icebergs.indices))
    }

    private func shuffleIcebergVertically(at indices: [Int]) {
        var yOrigin = icebergInitYOrigin
        for index in 0..<icebergs.count {
            let randomIndex = Int.random(in: 0 ..< yOrigin.count)
            self.icebergs[index].origin.yCoordinate = yOrigin.remove(at: randomIndex)
        }
    }

    private func shuffleIcebergHorizontally(at indices: [Int]) {
        var xOrigin = icebergInitXOrigin
        indices.forEach({index in
            let randomIndex = Int.random(in: 0 ..< xOrigin.count)
            icebergs[index].origin.xCoordinate = xOrigin.remove(at: randomIndex)
        })
    }
}

// MARK: - Constants
extension TitanicGame {

    var countdownBeginningValue: Int {30}
    private var moveFactor: Double {10}
    private var maximumCrashs: Int {5}
    private var startKnots: Int {50}
    private var knotsReducer: Int {5}
}
