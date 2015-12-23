//
//  GameScene.swift
//  ZombieConga
//
//  Created by Zhe Cui on 11/14/15.
//  Copyright (c) 2015 Zhe Cui. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var lastUpdateLocation = CGPoint.zero
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "hitCatLady.wav", waitForCompletion: false)
    var zombieIsInvincible = false
    let pointsPerSec: CGFloat = 480.0
    var lives = 5
    var gameOver = false
    
    func loseCats() {
        // 1
        var loseCount = 0
        enumerateChildNodesWithName("train") { node, stop in
            // 2
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            // 3
            node.name = ""
            node.runAction(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.rotateByAngle(π*4, duration: 1.0),
                        SKAction.moveTo(randomSpot, duration: 1.0),
                        SKAction.scaleTo(0, duration: 1.0)
                    ]),
                    SKAction.removeFromParent()
                ])
            )
            // 4
            loseCount++
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func moveTrain() {
        var trainCount = 0
        var targetPosition = zombie.position
        enumerateChildNodesWithName("train") {
            node, stop in
            trainCount++
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.pointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y,
                                    duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        if trainCount >= 10 && !gameOver {
            gameOver = true
            print("You win!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        cat.runAction(SKAction.colorizeWithColor(SKColor.greenColor(),
            colorBlendFactor: 1.0, duration: 0.2))
                
        //cat.removeFromParent()
        runAction(catCollisionSound)
            //runAction(SKAction.playSoundFileNamed("hitCat.wav",
            //waitForCompletion: false))
    }
    func zombieHitEnemy(enemy: SKSpriteNode) {
        enemy.removeFromParent()
        runAction(enemyCollisionSound)
        loseCats()
        lives--
        
        zombieIsInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
            node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let zombieShowAndVincible = SKAction.runBlock() {
            self.zombie.hidden = false
            self.zombieIsInvincible = false
        }
        zombie.runAction(SKAction.sequence([blinkAction, zombieShowAndVincible]))

        //runAction(SKAction.playSoundFileNamed("hitCatLady.wav",
            //waitForCompletion: false))
    }
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        if !zombieIsInvincible {
            var hitEnemies: [SKSpriteNode] = []
            enumerateChildNodesWithName("enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                if CGRectIntersectsRect(
                    //CGRectInset(node.frame, -20, -20), self.zombie.frame) {
                    node.frame, self.zombie.frame) {
                        hitEnemies.append(enemy)
                }
            }
            for enemy in hitEnemies {
                zombieHitEnemy(enemy)
            }
        }
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: CGRectGetMinX(playableRect),
                                max: CGRectGetMaxX(playableRect)),
            y: CGFloat.random(min: CGRectGetMinY(playableRect),
                                max: CGRectGetMaxY(playableRect)))
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        //let wait = SKAction.waitForDuration(10.0)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        //let wiggleWait = SKAction.repeatAction(fullWiggle, count: 10)
        
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence(
                [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeatAction(group, count: 10)
        
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func spawnEnemy() {
        //let enemy = SKSpriteNode(imageNamed: "enemy")
        let catLady = SKSpriteNode(imageNamed: "enemy")
        let enemy0 = SKSpriteNode(imageNamed: "projectile_1x")
        enemy0.color = SKColor.magentaColor()
        enemy0.colorBlendFactor = 0.2
        let enemy1 = SKSpriteNode(imageNamed: "projectile_2x")
        enemy1.color = SKColor.cyanColor()
        enemy1.colorBlendFactor = 0.2
        let enemies = [enemy0, enemy1]
        let enemy = enemies[Int(arc4random_uniform(UInt32(enemies.count)))]
        catLady.name = "catLady"
        enemy.name = "enemy"
        let randomPoint = randomOnRectCircumference(playableRect)
        catLady.position = randomPoint.point
        /*
        catLady.position = CGPoint(
            x: size.width - catLady.size.width/2,
            y: CGFloat.random(
                min: CGRectGetMinY(playableRect) + catLady.size.height/2,
                max: CGRectGetMaxY(playableRect) - catLady.size.height/2))
        */
        enemy.position = catLady.position
        
        let enemyOnRectSide = randomPoint.side
        var actionMove: SKAction
        switch enemyOnRectSide {
        case 0: // left side
            catLady.zRotation = π
            actionMove = SKAction.moveToX(CGRectGetMaxX(playableRect), duration: 2.0)
        case 1: // top side
            catLady.zRotation = π / 2
            actionMove = SKAction.moveToY(CGRectGetMinY(playableRect), duration: 2.0)
        case 3: // bottom side
            catLady.zRotation = -π / 2
            actionMove = SKAction.moveToY(CGRectGetMaxY(playableRect), duration: 2.0)
        default: // right side
            actionMove = SKAction.moveToX(CGRectGetMinX(playableRect), duration: 2.0)
        }
        
        addChild(enemy)
        addChild(catLady)
        
        enemy.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.scaleTo(4.0, duration: 2.0),
                SKAction.rotateByAngle(π * 4, duration: 2.0),
                actionMove]),
            SKAction.removeFromParent()]))
        catLady.runAction(SKAction.sequence([
            SKAction.waitForDuration(2.0),
            SKAction.removeFromParent()]))
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        /*
        sprite.zRotation = CGFloat(
        atan2(Double(direction.y), Double(direction.x)))
        */
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: direction.angle)
        let amountToRotate = min(rotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amountToRotate
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin,
            width: size.width, height: playableHeight)
        //print("playableRect x: \(CGRectGetMinX(playableRect)), y: \(CGRectGetMinY(playableRect)), width: \(playableRect.width) height: \(playableRect.height)")
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
                textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.animateWithTextures(textures,
                timePerFrame: 0.1)
        super.init(size: size)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented") // 6
    }
    func debugDrawPlayableArea() {
            let shape = SKShapeNode()
            let path = CGPathCreateMutable()
            CGPathAddRect(path, nil, playableRect)
            shape.path = path
            shape.strokeColor = SKColor.redColor()
            shape.lineWidth = 4.0
            addChild(shape)
    }
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        //print("amount to move: \(amountToMove)")
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        startZombieAnimation()
        let offset = location - zombie.position
        /*
        let length = sqrt(
            Double(offset.x * offset.x + offset.y * offset.y))
        */
        let direction = offset.normalized()
        /*
        let direction = CGPoint(x: offset.x / CGFloat(length),
            y: offset.y / CGFloat(length))
        velocity = CGPoint(x: direction.x * zombieMovePointsPerSec,
                            y: direction.y * zombieMovePointsPerSec)
        */
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        lastUpdateLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: size.width, y: CGRectGetMaxY(playableRect))
        if (zombie.position.x <= bottomLeft.x) {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if (zombie.position.y <= bottomLeft.y) {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if (zombie.position.x >= topRight.x) {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if (zombie.position.y >= topRight.y) {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }

    override func touchesBegan(touches: Set<UITouch>,
        withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    override func touchesMoved(touches: Set<UITouch>,
        withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func startZombieAnimation() {
            if zombie.actionForKey("animation") == nil {
            zombie.runAction(
            SKAction.repeatActionForever(zombieAnimation),
            withKey: "animation")
            } }
    func stopZombieAnimation() {
            zombie.removeActionForKey("animation")
    }
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("backgroundMusic.mp3")
        backgroundColor = SKColor.blackColor()
        // background
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //background.anchorPoint = CGPoint.zero
        //background.position = CGPoint.zero
        //background.zRotation = CGFloat(M_PI) / 8
        background.zPosition = -1
        addChild(background)
        //let mySize = background.size
        //print("Size: \(mySize)")
        
        // zombie
        zombie.position = CGPoint(x: size.width/4, y: size.height/2)
        zombie.zPosition = 100
        //zombie.setScale(2)
        addChild(zombie)
        //zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        //spawnEnemy()
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2.0)])))
        
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1.0)])))
        debugDrawPlayableArea()
    }
    override func didEvaluateActions() {
        checkCollisions()
    }
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        //print("\(dt * 1000) ms since last update")
        //zombie.position = CGPoint(x: zombie.position.x + 8, y: zombie.position.y)
        let offset = lastUpdateLocation - zombie.position
        if offset.length() <= zombieMovePointsPerSec * CGFloat(dt) {
            zombie.position = lastUpdateLocation
            velocity = CGPoint.zero
            stopZombieAnimation()
        }
        rotateSprite(zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
        moveSprite(zombie, velocity: velocity)
        moveTrain()
        boundsCheckZombie()
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
        //checkCollisions()
    }
}
