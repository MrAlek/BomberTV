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


class GameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
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

        /* Sprite Kit applies additional optimizations to improve rendering performance */
        gameView.ignoresSiblingOrder = true
        gameView.presentScene(scene)

        GameClient.sharedClient.callbacks.playerDidJoin = { [weak self] (id, face) in
            self!.scene.addPlayerWithId(id: id, face: face)
            self!.tableView.reloadData()
        }

        GameClient.sharedClient.callbacks.playerDidLeave = { [weak self] (id) in
            self!.scene.removePlayerWithId(id: id)
            self!.tableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lol") ?? UITableViewCell(style: .value2, reuseIdentifier: "lol")
        
        //cell.textLabel?.text = "Löl"
        cell.textLabel?.text = Array(scene.allThemPlayers.values)[indexPath.row].face
        //cell.textLabel?.font = UIFont(name: "System", size: 36)
        //cell.detailTextLabel?.text = "4"
        cell.detailTextLabel?.textColor = .black
        //cell.detailTextLabel?.font = UIFont(name: "System", size: 18)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scene.allThemPlayers.count
        //return 10
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 26
    }
}
