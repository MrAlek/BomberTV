//
//  JSONExtensions.swift
//
//  Created by Alek Åström on 2015-10-12.
//  Copyright © 2015 Dooer AB. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    enum Error: Swift.Error {
        case NotADictionary
        case NotAString
        case NotAnArray
        case NotADouble
    }
    
    func assert<T: JSONParsable>(key: String, type: T.Type) throws {
        guard case .dictionary = self.type else {
            throw Error.NotADictionary
        }
        try T.assert(json: self[key])
    }
    
    func get<T: JSONParsable>(key: String) throws -> T {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        return try T(self[key])
    }
    
    func get(key: String) throws -> String {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        guard let string = self[key].string else {
            throw Error.NotAString
        }
        
        return string
    }
    func get(key: String) throws -> [JSON] {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        guard let array = self[key].array else {
            throw Error.NotAnArray
        }
        
        return array
    }
    func get(key: String) throws -> [[String: JSON]] {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        guard let array = self[key].array else {
            throw Error.NotAnArray
        }
        
        return try array.map() { try $0.dictionary() }
    }
    
    func get(key: String) throws -> [String: JSON] {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        guard let dictionary = self[key].dictionary else {
            throw Error.NotADictionary
        }
        
        return dictionary
    }
    
    func get(key: String) throws -> Double {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        guard let double = self[key].double else {
            throw Error.NotADouble
        }
        
        return double
    }
    
    func getOptional(key: String) throws -> [JSON]? {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        return self[key].array
    }
    
    func getOptional(key: String) throws -> [String: JSON]? {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        return self[key].dictionary
    }
    
    func getOptional(key: String) throws -> String? {
        guard case .dictionary = type else {
            throw Error.NotADictionary
        }
        
        return self[key].string
    }
    
    private func dictionary() throws -> [String: JSON] {
        guard let dictionary = dictionary else {
            throw Error.NotADictionary
        }
        return dictionary
    }
}

extension JSON {
    func hasKey(key: String) -> Bool {
        return self[key].null == nil
    }
}
