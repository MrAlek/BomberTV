//
//  GameViewController.swift
//  bomberTV
//
//  Created by Alek Åström on 2015-11-02.
//  Copyright (c) 2015 bomber. All rights reserved.
//

import UIKit
import QuartzCore
import SpriteKit


class GameViewController: UIViewController {
    
    
    @IBOutlet weak var gameView: SKView!
    
    lazy var scene: GameScene = {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameView.showsFPS = true
        gameView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        gameView.ignoresSiblingOrder = true
        gameView.presentScene(scene)
        
        /*let flake: UIImage = UIImage(named: "snowflake")!

        let snowflake = Snowflake(view: snowView, particles: [flake: .white])
        
        snowView.layer.addSublayer(snowflake)*/

        GameClient.sharedClient.callbacks.playerDidJoin = { [weak self] (id, face) in
            self!.scene.addPlayerWithId(id: id, face: face)
        }

        GameClient.sharedClient.callbacks.playerDidLeave = { [weak self] (id) in
            self!.scene.removePlayerWithId(id: id)
        }

        GameClient.sharedClient.callbacks.didUpdateMove = { [weak self] (id, point) in
            let vec = CGVector(dx: point.x, dy: point.y)
            self?.scene.allThemPlayers[id]?.vec = vec
        }
        
        GameClient.sharedClient.callbacks.didDropBomb = { [weak self] id in
            self?.scene.allThemPlayers[id]?.shouldDropBomb = true
        }
        
        GameClient.sharedClient.callbacks.playerDidRespawn = { [weak self] id in
            self?.scene.respawnPlayer(id: id)
        }
    }
}
