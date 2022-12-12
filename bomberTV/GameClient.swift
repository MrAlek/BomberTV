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
        method = try json.get(key: "method")
        params = try json.get(key: "params")
    }
}

extension CGPoint: JSONParsable {
    init(_ json: JSON) throws {
        let x: Double = try json.get(key: "x")
        let y: Double = try json.get(key: "y")
        
        self.init()
        self.x = CGFloat(x)
        self.y = CGFloat(y)
    }
}


class GameClient {
    struct Callbacks {
        var playerDidJoin: ((String, String) -> Void)? = nil
        var playerDidLeave: ((String) -> Void)? = nil
        var didUpdateMove: ((String, CGPoint) -> Void)? = nil
        var didDropBomb: ((String) -> Void)? = nil
        var playerDidRespawn: ((String) -> Void)? = nil
    }
    var callbacks = Callbacks()
    let request = URLRequest(url: URL(string: "ws://192.168.0.46:4940/")!)
    
    var socket: WebSocket;
    
    static let sharedClient = GameClient()
    
    init() {
        socket = WebSocket(request: request)
        socket.onEvent = { event in
            switch event {
            case .connected(_):
                print("Connected!")
                self.sendRegister()
            case .text(let text):
                self.handleString(string: text)
            case .binary(let data):
                self.handleData(data: data)
            default:
                return
            }
        }
        socket.connect()
    }
    
    func handleString(string: String) {
        if let dataFromString = string.data(using: .utf8, allowLossyConversion: false), let json = try? JSON(data: dataFromString) {
            handleJSON(json: json)
        }
    }
    
    func handleData(data: Data) {
        if let json = try? JSON(data: data) {
            handleJSON(json: json)
        }
    }
    
    func handleJSON(json: JSON) {
        //print("Received json: \(json)")
        
        guard let message = try? Message(json) else {
            print("Got JSON which isn't a message!"); return
        }
        
        if message.method == "join" {
            let id = message.params["id"]!.stringValue
            let face = message.params["face"]!.stringValue
            
            callbacks.playerDidJoin?(id, face)
        } else if message.method == "leave" {
            let id = message.params["player"]!.stringValue
            
            callbacks.playerDidLeave?(id)
        } else if message.method == "move" {
            let point = try! CGPoint(message.params)
            let id = message.params["player"]!.stringValue
            
            callbacks.didUpdateMove?(id, point)
        } else if message.method == "bomb" {
            let id = message.params["player"]!.stringValue
            callbacks.didDropBomb?(id)
        } else if message.method == "respawn" {
            let id = message.params["player"]!.stringValue
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
        socket.write(data: try! json.rawData())
    }
    
    func sendPlayerDied(id: String) {
        let json: JSON = [
            "method": "die",
            "params": [
                "player": id
            ]
        ]
        socket.write(data: try! json.rawData())
    }
    
}
