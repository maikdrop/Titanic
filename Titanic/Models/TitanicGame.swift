//
//  Titanic.swift
//  Titanic
//
//  Created by Maik on 01.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

class TitanicGame {

     // MARK: - Properties
    private var icebergInitXOrigin = [Double]()
    private var icebergInitYOrigin = [Double]()
    private var distanceBetweenIcebergs = 0.0
    private(set) var icebergs = [Iceberg]()

     // MARK: - Creating a Titanic Game
    init(icebergInitXOrigin: [Double], icebergInitYOrigin: [Double], icebergSize: [(width: Double, height: Double)]) {
        self.icebergInitXOrigin = icebergInitXOrigin
        self.icebergInitYOrigin = icebergInitYOrigin
        for index in 0..<icebergInitXOrigin.count {
            let origin = Point(
                xCoordinate: icebergInitXOrigin[index],
                yCoordinate: icebergInitYOrigin[index])
            let size = Size(width: icebergSize[index].width, height: icebergSize[index].height)
            let iceberg = Iceberg(origin: origin, size: size)
            icebergs += [iceberg]
        }
        distanceBetweenIcebergs = calculateDistanceBetweenIcebergs()
        shuffleIcebergVertically(at: Array(icebergs.indices))
    }

    deinit {
        print("DEINIT Titanic")
    }
}

  // MARK: - Public API to control a Titanic Game
extension TitanicGame {

    func moveIcebergVertically(by factor: Double) {
        for index in 0..<icebergs.count {
            icebergs[index].center.yCoordinate += factor
        }
    }

    func resetIcebergVertically(at index: Int) {
        if let icebergWithSmallestY = icebergs.min() {
            icebergs[index].origin.yCoordinate = icebergWithSmallestY.origin.yCoordinate - distanceBetweenIcebergs
        }
        shuffleIcebergHorizontally(at: [index])

    }

    func resetAllIcebergsVerticallyAndHorizontally() {
        shuffleIcebergHorizontally(at: Array(icebergs.indices))
        shuffleIcebergVertically(at: Array(icebergs.indices))
    }
}

// MARK: - Private methods to customize the behavior of a Titanic Game
private extension TitanicGame {

    private func shuffleIcebergHorizontally(at indices: [Int]) {
        var xOrigin = icebergInitXOrigin
        indices.forEach({index in
            let randomIndex = Int.random(in: 0 ..< xOrigin.count)
            icebergs[index].origin.xCoordinate = xOrigin.remove(at: randomIndex)
        })
    }

    private func shuffleIcebergVertically(at indices: [Int]) {
        var yOrigin = icebergInitYOrigin
        for index in 0..<icebergs.count {
            let randomIndex = Int.random(in: 0 ..< yOrigin.count)
            self.icebergs[index].origin.yCoordinate = yOrigin.remove(at: randomIndex)
        }
    }

    private func calculateDistanceBetweenIcebergs() -> Double {
        if icebergs.count > 1 {
            return abs(icebergs[0].origin.yCoordinate.distance(to: icebergs[1].origin.yCoordinate))
        }
        return 0
    }
}
