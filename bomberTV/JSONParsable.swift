//
//  JSONParsable.swift
//
//  Created by Alek Åström on 2015-10-07.
//  Copyright © 2015 Dooer AB. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONParsable {
    init(_ json: JSON) throws
}

extension JSONParsable {
    
    static func parse(json: JSON) throws -> Self {
        return try Self(json)
    }
    
    static func parse(json: JSON?) throws -> Self? {
        return try json.map(Self.init)
    }
    
    static func assert(json: JSON) throws {
        try Self(json)
    }
    
    init(_ json: [String: JSON]) throws {
        try self.init(JSON(json))
    }
}

extension CollectionType where Generator.Element == JSON {
    func parseArray<T: JSONParsable>() throws -> [T] {
        return try map(T.init)
    }
}
