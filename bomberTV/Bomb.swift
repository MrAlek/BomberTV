//
//  Bomb.swift
//  bomberTV
//
//  Created by Alek Åström on 2015-11-04.
//  Copyright © 2015 bomber. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    
    static func bomb(size: CGFloat) -> SKSpriteNode {
        let bomb = SKSpriteNode(text: "💣", size: size)
        bomb.name = "bomb"
        bomb.zPosition = -1
        return bomb
    }
}
