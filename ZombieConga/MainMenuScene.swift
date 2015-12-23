//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Zhe Cui on 12/19/15.
//  Copyright © 2015 Zhe Cui. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position =
            CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = scaleMode
        // 2
        let reveal = SKTransition.doorwayWithDuration(1.5)
        // 3
        view?.presentScene(gameScene, transition: reveal)
    }
}
