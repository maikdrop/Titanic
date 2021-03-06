/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import SpriteKit

final class SmokeView: SKView {

    // MARK: - Properties
    private let intersectionPoint: CGPoint

    private lazy var newScene: SKScene = {
        let scene = SKScene(size: frame.size)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        scene.anchorPoint = frame.origin
        return scene
    }()

    private lazy var emitterNode: SKEmitterNode? = {
        if let emitterNode = SKEmitterNode(fileNamed: "Smoke.sks") {
            emitterNode.position.x = self.intersectionPoint.x
            emitterNode.position.y = frame.height - self.intersectionPoint.y
            return emitterNode
        }
        return nil
    }()

    // MARK: - Creating a SmokeView
    init(frame: CGRect, intersectionPoint: CGPoint) {
        self.intersectionPoint = intersectionPoint
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("DEINIT SmokeView")
    }
}

// MARK: - Default Methods
extension SmokeView {

    override func didMoveToSuperview() {
        guard superview != nil else {
            return
        }
        if let emitterNode = emitterNode {
           newScene.addChild(emitterNode)
           presentScene(newScene)
        }
    }
}
