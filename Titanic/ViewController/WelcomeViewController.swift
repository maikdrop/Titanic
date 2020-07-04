//
//  WelcomeViewController.swift
//  Titanic
//
//  Created by Maik on 04.04.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var startBtn: UIButton! {
        didSet {
            startBtn.titleLabel?.adjustsFontForContentSizeCategory = true
            startBtn.isEnabled = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        let imageView = UIImageView(image: UIImage(named: "LaunchImage"))
        imageView.center = startBtn.center
        view.addSubview(imageView)
        let ratio = view.frame.width / imageView.frame.width
        UIView.transition(
            with: imageView,
            duration:  0.6,
            options: [],
            animations: {
                imageView.transform = CGAffineTransform.identity.scaledBy(x: ratio, y: ratio)
            },
            completion: { _ in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.75,
                    delay: 0,
                    options: [],
                    animations: {
                        imageView.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                    imageView.alpha = 0
                    },
                    completion: { _ in
                        self.startBtn.isEnabled = true
                        imageView.isHidden = true
                        imageView.alpha = 1
                        imageView.transform = .identity
                    }
                )
            }
        )
    }
}
