//
//  GameScene.swift
//  Fear The Dead
//
//  Created by Morten Faarkrog on 08/09/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Instance Variables
    
    let playerSpeed: CGFloat = 150.0
    var player: SKSpriteNode?
    
    var lastTouch: CGPoint? = nil {
        didSet {
            //print("Move updated: \(lastTouch)")
        }
    }
    
    // MARK: - SKScene
    
    override func didMoveToView(view: SKView) {
        // Setup physics world's contact delegate
        physicsWorld.contactDelegate = self
        
        // Setup player
        player = self.childNodeWithName("player") as? SKSpriteNode
    
        // Setup initial camera position
        updateCamera()
    }
    
    
    // MARK: Touch Handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        handleTouches(touches)
    }
    
    private func handleTouches(touches: Set<UITouch>) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            lastTouch = touchLocation
        }
    }
    
    
    // MARK - Updates
    
    override func didSimulatePhysics() {
        if let _ = player {
            updatePlayer()
        }
    }
    
    // Determines if the player's position should be updated
    private func shouldMove(currentPosition currentPosition: CGPoint, touchPosition: CGPoint) -> Bool {
        return abs(currentPosition.x - touchPosition.x) > player!.frame.width / 2 ||
            abs(currentPosition.y - touchPosition.y) > player!.frame.height/2
    }
    
    // Updates the player's position by moving towards the last touch made
    func updatePlayer() {
        if let touch = lastTouch {
            let currentPosition = player!.position
            if shouldMove(currentPosition: currentPosition, touchPosition: touch) {
                
                let angle = atan2(currentPosition.y - touch.y, currentPosition.x - touch.x) + CGFloat(M_PI)
                let rotateAction = SKAction.rotateToAngle(angle + CGFloat(M_PI*0.5), duration: 0)
                
                player!.runAction(rotateAction)
                
                let velocotyX = playerSpeed * cos(angle)
                let velocityY = playerSpeed * sin(angle)
                
                let newVelocity = CGVector(dx: touch.x*playerSpeed, dy: touch.y*playerSpeed)
                player!.physicsBody!.velocity = newVelocity;
                updateCamera()
            } else {
                player!.physicsBody!.resting = true
            }
        }
    }
    
    func updateCamera() {
        if let camera = camera {
            camera.position = CGPoint(x: player!.position.x, y: player!.position.y)
        }
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
