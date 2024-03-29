//
//  GameScene.swift
//  Fear The Dead
//
//  Created by Morten Faarkrog on 08/09/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import SpriteKit

let PlayerPointSize: CGFloat = 60.0
let Padding: CGFloat = 128.0

class RemotePlayer {
    var id: String
    var vec: CGVector
    var face: String
    var node: SKNode
    var dead: Bool = false
    var shouldDropBomb: Bool = false
    
    init(id: String, face: String) {
        self.face = face
        self.id = id
        self.node = NewPlayerNode(id: id, text: face)
        self.vec = CGVector(dx: 0, dy: 0)
    }
}

func NewPlayerNode(id: String, text: String) -> SKNode {
    let node = SKSpriteNode(text: text, size: PlayerPointSize)
    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2.0)
    node.physicsBody!.affectedByGravity = false
    node.physicsBody!.contactTestBitMask = 2
    node.physicsBody!.categoryBitMask = 1
    node.userData = ["id": id]
    node.name = "player"
    return node
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Instance Variables
    
    let playerSpeed: CGFloat = 300.0
    
    var lastTouch: CGPoint = CGPoint(x: 0, y: 0)
    var shouldDropBomb: Bool = false
    
    var allThemPlayers: [String: RemotePlayer] = [:]
    
    // MARK: - SKScene
    
    override func didMove(to view: SKView) {
        // Setup physics world's contact delegate
        physicsWorld.contactDelegate = self
    }
    
    // MARK - Updates
    
    override func didSimulatePhysics() {
        for (_, player) in allThemPlayers {
            updatePlayerPosition(player: player)
            if player.shouldDropBomb {
                dropBombAtPosition(position: player.node.position)
                player.shouldDropBomb = false
            }
        }
    }
    
    func updatePlayerPosition(player: RemotePlayer) {
        let dx = player.vec.dx * playerSpeed
        let dy = player.vec.dy * playerSpeed
        
        if (abs(dx) + abs(dy) <= 0.0001) {
            player.node.physicsBody!.isResting = true
            return
        }
        
        let angle = atan2(dy, dx) + (CGFloat(Double.pi) / 2)
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0)
        let newVelocity = CGVector(dx: dx, dy: dy)
        
        player.node.run(rotateAction)
        player.node.physicsBody!.velocity = newVelocity
    }
    
    func addPlayerWithId(id: String, face: String) {
        let player = RemotePlayer(id: id, face: face)
        placePlayerNode(node: player.node)
        allThemPlayers[id] = player
    }
    
    func placePlayerNode(node: SKNode) {
        let corner = Int(arc4random_uniform(4))
        
        switch (corner) {
        case 0: node.position = CGPoint(x: Padding, y: Padding)
        case 1: node.position = CGPoint(x: size.width - Padding, y: Padding)
        case 2: node.position = CGPoint(x: Padding, y: size.height - Padding)
        case 3: node.position = CGPoint(x: size.width - Padding, y: size.height - Padding)
        default: fatalError()
        }
        
        addChild(node)
    }

    func removePlayerWithId(id: String) {
        if let player = allThemPlayers[id] {
            player.node.removeFromParent()
            allThemPlayers.removeValue(forKey: id)
        }
    }

    func dropBombAtPosition(position: CGPoint) {
        let bomb = SKSpriteNode.bomb(size: PlayerPointSize)
        bomb.position = position
        addChild(bomb)
        
        run(SKAction.wait(forDuration: 2), completion: { [weak self] in
            bomb.removeFromParent()
            self!.addExplosionAtPosition(position: position)
            })
    }
    
    func addExplosionAtPosition(position: CGPoint) {
        let emitterNode = SKEmitterNode(fileNamed: "Explosion")!
        emitterNode.particlePosition = position
        addChild(emitterNode)
        
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(circleOfRadius: 50)
        node.position = position
        node.physicsBody!.categoryBitMask = 2
        node.physicsBody!.collisionBitMask = 0
        node.name = "explosion"
        addChild(node)
        
        run(SKAction.wait(forDuration: 2), completion: {
            emitterNode.removeFromParent()
            node.removeFromParent()
        })
    }
    
    // MARK: - SKPhysicsContactDelegate

    
    func didBegin(_ contact: SKPhysicsContact) {
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
        
        if firstBody.node?.name == "player" && secondBody.node?.name == "explosion" {
            killPlayer(node: firstBody.node!)
        }
    }
    
    func killPlayer(node: SKNode) {
        let playerId = node.userData!["id"] as! String
        
        let player = allThemPlayers[playerId]!
        if player.dead { return }
        
        player.dead = true
        node.physicsBody!.collisionBitMask = 0
        GameClient.sharedClient.sendPlayerDied(id: playerId)
        let fadeoutAction = SKAction.fadeOut(withDuration: 1)
        let scaleAction = SKAction.scale(by: 10.0, duration: 1)
        let rotateAction = SKAction.rotate(byAngle: CGFloat.pi*5, duration: 1)
        let group = SKAction.group([fadeoutAction, scaleAction, rotateAction])
        let removeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([group, removeAction]))
    }
    
    func respawnPlayer(id: String) {
        let player = allThemPlayers[id]!
        player.node = NewPlayerNode(id: player.id, text: player.face)
        placePlayerNode(node: player.node)
        player.dead = false
    }
    
}
