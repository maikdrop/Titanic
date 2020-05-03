//
//  SmokeView.swift
//  Titanic
//
//  Created by Maik on 03.05.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import SpriteKit

class SmokeView: SKView {
    
    private lazy var newScene: SKScene? = {
        let scene = SKScene(size: frame.size)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        scene.anchorPoint = frame.origin
        if let emitterNode = self.emitterNode {
            scene.addChild(emitterNode)
            return scene
        }
        return nil
    }()
    
    private lazy var emitterNode: SKEmitterNode? = {
        if let sv = superview as? GameView {
            if let emitterNode = SKEmitterNode(fileNamed: "Smoke.sks") {
                emitterNode.position.x = sv.ship.frame.midX
                emitterNode.position.y = sv.ship.frame.size.height * 2
                return emitterNode
            }
        }
        return nil
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard superview != nil else {
            return
        }
        presentScene(newScene)
    }
}
