//
//  Type.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum Type {
    indirect case Normal(String, [Type])
    indirect case Tuple([Type])
    indirect case Function(Type, Type)
}

extension Type {
    var identifier: String {
        switch self {
        case .Normal(let i, _):
            return i
        default:
            fatalError("Type isn't generic type \(self.description)")
        }
    }
}

extension Type: CustomStringConvertible {
    static var void: Type {
        return Type.Normal("Void", [])
    }
    
    var isOptional: Bool {
        switch self {
        case .Normal(let identifier, _):
            return identifier == "Optional"
        default:
            return false
        }
    }
    
    var isArray: Bool {
        switch self {
        case .Normal(let identifier, _):
            return identifier == "Array"
        default:
            return false
        }
    }

    var isDictionary: Bool {
        switch self {
        case .Normal(let identifier, _):
            return identifier == "Dictionary"
        default:
            return false
        }
    }
    
    var description: String {
        switch self {
        case .Normal(let identifier, let ga):
            let genericArguments = ga.count > 0 ? "<" + ", ".join(ga.map { $0.description }) + ">" : ""
            return "\(identifier)\(genericArguments)"
        case .Tuple(let types):
            return "(" + ", ".join(types.map { $0.description }) + ")"
        case .Function(let l, let r):
            return l.description + " -> " + r.description
        }
    }
}

