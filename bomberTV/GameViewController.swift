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

extension SKNode {
    
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
    
}


class GameViewController: UIViewController {
    
    
    lazy var scene: GameScene = {
        let scene = GameScene.unarchiveFromFile("GameScene") as! GameScene
        // Configure the view.
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        return scene
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)

        GameClient.sharedClient.callbacks.playerDidJoin = { [weak self] (id, face) in
            self!.scene.addPlayerWithId(id, face: face)
        }

        GameClient.sharedClient.callbacks.playerDidLeave = { [weak self] (id) in
            self!.scene.removePlayerWithId(id)
        }

        GameClient.sharedClient.callbacks.didUpdateMove = { [weak self] (id, point) in
            let vec = CGVector(dx: point.x, dy: point.y)
            self?.scene.allThemPlayers[id]?.vec = vec
        }
        
        GameClient.sharedClient.callbacks.didDropBomb = { [weak self] id in
            self?.scene.allThemPlayers[id]?.shouldDropBomb = true
        }
        
        GameClient.sharedClient.callbacks.playerDidRespawn = { [weak self] id in
            self?.scene.respawnPlayer(id)
        }
    }
}
