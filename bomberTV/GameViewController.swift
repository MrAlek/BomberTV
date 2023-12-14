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
    
    lazy var scene: GameScene = GameScene.newGameScene()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gameView.presentScene(scene)
        gameView.ignoresSiblingOrder = true

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
        
        GameClient.sharedClient.callbacks.playerKilled = { [weak self] id in
            /*
            let playersSortedByScore = self!.scene.allThemPlayers.values.sorted { l, r in
                l.score > r.score
            }
            
            
            if let player = playersSortedByScore.first, player.score >= 20 {
                let alert = UIAlertController(title: "We have a winner!", message: "Congratulations \(player.face). You are the fiercest warrior at Done. Redeem your price under the Marshall 👨‍✈️.", preferredStyle: .alert)
                let firstAction = UIAlertAction(title: "🥇", style: .default) { [weak self] _ in
                    
                    let message = """
                    Oh I haven't felt this way in years! Watching you fight so fiercly in battle has made me convinced. You can take down the 👹, and I will help you. Here is a clue:
                    
                    A place to keep your ride safe and sound,
                    Where wind and cold can't be found.
                    A place to store your two-wheeled friend,
                    Where you can make sure it won't bend.

                    A place to keep your ride secure,
                    Where you can be sure
                    That there will be no sabotage
                    In fact it is a _____________
                    """
                    
                    let alert = UIAlertController(title: "Such bravery, such action!", message: message, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Go get 'em!", style: .default)
                    alert.addAction(action)
                    self!.present(alert, animated: true)
                }
                alert.addAction(firstAction)
                self!.present(alert, animated: true)
            }*/
            self!.tableView.reloadData()
        }
        
        GameClient.sharedClient.callbacks.playerDidRespawn = { [weak self] id in
            self?.scene.respawnPlayer(id: id)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            let alert = UIAlertController(title: "First one to 20 wins!", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "En garde!", style: .default)
            alert.addAction(action)
            self!.present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lol") ?? UITableViewCell(style: .value2, reuseIdentifier: "lol")
        
        let player = Array(scene.allThemPlayers.values)[indexPath.row]
        cell.textLabel?.text = player.face
        cell.detailTextLabel?.text = String(player.score)
        cell.detailTextLabel?.textColor = .black
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scene.allThemPlayers.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 26
    }
}
