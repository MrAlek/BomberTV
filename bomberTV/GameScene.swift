//
//  GameScene.swift
//  Fear The Dead
//
//  Created by Morten Faarkrog on 08/09/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import SpriteKit

let PlayerPointSize: CGFloat = 60.0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Instance Variables
    
    let playerSpeed: CGFloat = 300.0
    var player: SKSpriteNode?
    
    var lastTouch: CGPoint = CGPoint(x: 0, y: 0)
    var shouldDropBomb: Bool = false
    
    // MARK: - SKScene
    
    override func didMoveToView(view: SKView) {
        // Setup physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        // Setup player
        player = childNodeWithName("player") as? SKSpriteNode
        
        let label = UILabel()
        
        label.font = UIFont.systemFontOfSize(40)
        label.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize().width, height: label.intrinsicContentSize().height)
        label.backgroundColor = UIColor.clearColor()
        
        player?.texture = SKTexture(image: "😈".renderWithSystemFontSize(PlayerPointSize))
        player?.size = player!.texture!.size()
    }
    
    // MARK - Updates
    
    override func didSimulatePhysics() {
        if let _ = player {
            updatePlayer()
        }
    }
    
    // Updates the player's position by moving towards the last touch made
    func updatePlayer() {
        let dx = lastTouch.x * playerSpeed
        let dy = lastTouch.y * playerSpeed
        
        if (abs(dx) + abs(dy) <= 0.0001) {
            player!.physicsBody!.resting = true
            return
        }
        
        let angle = atan2(dy, dx) + (CGFloat(M_PI) / 2)
        let rotateAction = SKAction.rotateToAngle(angle, duration: 0)
        let newVelocity = CGVector(dx: lastTouch.x * playerSpeed, dy: lastTouch.y * playerSpeed)
        
        player!.runAction(rotateAction)
        player!.physicsBody!.velocity = newVelocity
        
        
        if shouldDropBomb {
            dropBombAtPosition(player!.position)
            shouldDropBomb = false
        }
    }
    
    func dropBombAtPosition(position: CGPoint) {
        let bomb = SKSpriteNode.bomb(PlayerPointSize)
        bomb.position = position
        addChild(bomb)
        
        runAction(SKAction.waitForDuration(2), completion: { [weak self] in
            bomb.removeFromParent()
            self!.addExplosionAtPosition(position)
            })
    }
    
    func addExplosionAtPosition(position: CGPoint) {
        var emitterNode = SKEmitterNode(fileNamed: "Explosion")!
        emitterNode.particlePosition = position
        addChild(emitterNode)
        runAction(SKAction.waitForDuration(2), completion: { emitterNode.removeFromParent() })
    }
    
    // MARK: - SKPhysicsContactDelegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
    }
    
}
