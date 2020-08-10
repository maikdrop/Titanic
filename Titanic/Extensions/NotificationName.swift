//
//  NotificationName.swift
//  Titanic
//
//  Created by Maik on 09.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let ShipDidIntersectWithIceberg = Notification.Name("ShipDidIntersectWithIceberg")
    static let IcebergDidReachEndOfView = Notification.Name("IcebergDidReachEndOfView")
    static let GameDidEnd = Notification.Name("GameDidEnd")
}
