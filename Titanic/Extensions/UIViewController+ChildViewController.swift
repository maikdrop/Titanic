//
//  UIViewController+ChildViewController.swift
//  Titanic
//
//  Created by Maik on 26.08.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

//source: www.swiftbysundell.com/basics/child-view-controllers
extension UIViewController {
    
    /**
     Adds child view controller.
     
     - Parameter child: child view controller to add
     */
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /**
     Removes child view controller.
     */
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
