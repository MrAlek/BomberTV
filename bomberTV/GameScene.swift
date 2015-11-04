//
//  GameScene.swift
//  Fear The Dead
//
//  Created by Morten Faarkrog on 08/09/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import SpriteKit

let PlayerPointSize: CGFloat = 60.0

class RemotePlayer {
    var id: String
    var vec: CGVector
    var node: SKSpriteNode
    
    init(id: String, face: String) {
        self.id = id
        self.node = SKSpriteNode(text: face, size: PlayerPointSize)
        self.node.physicsBody = SKPhysicsBody(circleOfRadius: self.node.size.width / 2.0)
        self.node.physicsBody!.affectedByGravity = false
        self.vec = CGVector(dx: 0, dy: 0)
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Instance Variables
    
    let playerSpeed: CGFloat = 300.0
    
    var lastTouch: CGPoint = CGPoint(x: 0, y: 0)
    var shouldDropBomb: Bool = false
    
    var allThemPlayers: [String: RemotePlayer] = [:]
    
    // MARK: - SKScene
    
    override func didMoveToView(view: SKView) {
        // Setup physics world's contact delegate
        physicsWorld.contactDelegate = self
    }
    
    // MARK - Updates
    
    override func didSimulatePhysics() {
        for (_, player) in allThemPlayers {
            let dx = player.vec.dx * playerSpeed
            let dy = player.vec.dy * playerSpeed
            
            if (abs(dx) + abs(dy) <= 0.0001) {
                player.node.physicsBody!.resting = true
                return
            }
            
            let angle = atan2(dy, dx) + (CGFloat(M_PI) / 2)
            let rotateAction = SKAction.rotateToAngle(angle, duration: 0)
            let newVelocity = CGVector(dx: dx, dy: dy)
            
            player.node.runAction(rotateAction)
            player.node.physicsBody!.velocity = newVelocity
        }
    }
    
    func addPlayerWithId(id: String, face: String) {
        let player = RemotePlayer(id: id, face: face)
        
        addChild(player.node)
        allThemPlayers[id] = player
    }
    
    func updatePlayerWithId(id: String, vec: CGVector) {
        if let player = allThemPlayers[id] {
            player.vec = vec
        }
    }
    
    // Updates the player's position by moving towards the last touch made
    func updatePlayer() {
//        if shouldDropBomb {
//            dropBombAtPosition(player!.position)
//            shouldDropBomb = false
//        }
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
