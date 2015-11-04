//
//  GameClient.swift
//  bomberTV
//
//  Created by Alek Åström on 2015-11-02.
//  Copyright © 2015 bomber. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

enum MessageMethod: String {
    
    case Register = "register"
    
    
}

struct Message: JSONParsable {
    
    let method: String
    let params: [String: JSON]
    
    init(method: String, params: [String: JSON]) {
        self.method = method
        self.params = params
    }
    
    init(_ json: JSON) throws {
        method = try json.get("method")
        params = try json.get("params")
    }
}

extension CGPoint: JSONParsable {
    init(_ json: JSON) throws {
        let x: Double = try json.get("x")
        let y: Double = try json.get("y")
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}


class GameClient {
    struct Callbacks {
        var playerDidJoin: ((String, String) -> Void)? = nil
        var playerDidLeave: (String -> Void)? = nil
        var didUpdateMove: ((String, CGPoint) -> Void)? = nil
        var didDropBomb: (String -> Void)? = nil
        var playerDidRespawn: (String -> Void)? = nil
    }
    var callbacks = Callbacks()
    
   let socket = WebSocket(url: NSURL(string: "ws://172.16.9.141:4940/")!)
//    let socket = WebSocket(url: NSURL(string: "ws://127.0.0.1:4940/")!)
    
    static let sharedClient = GameClient()
    
    init() {
        socket.onConnect = { [unowned self] _ in
            print("Connected!")
            self.sendRegister()
        }
        socket.onText = handleString
        socket.onData = handleData
        socket.connect()
    }
    
    func handleString(string: String) {
        handleJSON(JSON(data: string.dataUsingEncoding(NSUTF8StringEncoding)!))
    }
    
    func handleData(data: NSData) {
        handleJSON(JSON(data: data))
    }
    
    func handleJSON(json: JSON) {
        //print("Received json: \(json)")
        
        guard let message = try? Message(json) else {
            print("Got JSON which isn't a message!"); return
        }
        
        if message.method == "join" {
            let id = String(message.params["id"]!)
            let face = String(message.params["face"]!)

            callbacks.playerDidJoin?(id, face)
        } else if message.method == "leave" {
            let id = String(message.params["player"]!)

            callbacks.playerDidLeave?(id)
        } else if message.method == "move" {
            let point = try! CGPoint(message.params)
            let id = String(message.params["player"]!)
            
            callbacks.didUpdateMove?(id, point)
        } else if message.method == "bomb" {
            let id = String(message.params["player"]!)
            callbacks.didDropBomb?(id)
        } else if message.method == "respawn" {
            let id = String(message.params["player"]!)
            callbacks.playerDidRespawn?(id)
        }
    }
    
    func sendRegister() {
        let json: JSON = [
            "method": "register",
            "params": [
                "client": "tv"
            ]
        ]
        socket.writeData(try! json.rawData())
    }
    
    func sendPlayerDied(id: String) {
        let json: JSON = [
            "method": "die",
            "params": [
                "player": id
            ]
        ]
        socket.writeData(try! json.rawData())
    }
    
}
