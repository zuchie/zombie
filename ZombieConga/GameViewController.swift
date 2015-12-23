//
//  GameViewController.swift
//  ZombieConga
//
//  Created by Zhe Cui on 11/14/15.
//  Copyright (c) 2015 Zhe Cui. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size: CGSize(width: 2048, height: 1536))
        //let scene = GameScene(size:CGSize(width: 2048, height: 1536))
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
            
        skView.presentScene(scene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
