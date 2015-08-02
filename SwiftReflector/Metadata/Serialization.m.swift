//
//  Serialization.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


extension SourceFile : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> SourceFile {
        return SourceFile(
            path: try Json.deserialize(json, "path"),
            declarations: try Json.deserialize(json, "declarations")
        )
    }
    
    func toJson() -> AnyObject {
        return [
            "path" : self.path,
            "declarations" : self.declarations.map {
                $0.toJson()
            }
        ]
    }
}

extension Declaration : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> Declaration {
        let type = try Json.deserialize(json, "type") as String
        
        if type == "import" {
            return .Import(module: try Json.deserialize(json, "module"))
        }
        else if type == "interface" {
            return .Interface(interface: try Json.deserialize(json, "interface"))
        }
        else if type == "function" {
            return .Function(function: try Json.deserialize(json, "function"))
        }
        else {
            fatalError("Unknown type \(type)")
        }
    }
    
    func toJson() -> AnyObject {
        switch self {
        case .Import(let module):
            return [
                "type" : "import",
                "module" : module
            ]
        case .Interface(let interface):
            return [
                "type" : "interface",
                "interface" : interface.toJson()
            ]
        case .Function(let function):
            return [
                "type" : "function",
                "function" : function.toJson()
            ]
        }
    }
}

extension InterfaceType : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> InterfaceType {
        return InterfaceType(rawValue: json as! Int)!
    }
    
    func toJson() -> AnyObject {
        return rawValue
    }
}

extension InterfaceMetadata : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> InterfaceMetadata {
        return InterfaceMetadata(
            interfaceType: try Json.deserialize(json, "interfaceType"),
            type: try Json.deserialize(json, "type"),
            inherits: try Json.deserialize(json, "inherits"),
            modifiers: try Json.deserialize(json, "modifiers"),
            properties: try Json.deserialize(json, "properties"),
            functions: try Json.deserialize(json, "functions"),
            enumCases: try Json.deserialize(json, "enumCases"),
            typealiases: try Json.deserialize(json, "typealiases"),
            serializedAttributes: try Json.deserialize(json, "serializedAttributes")
        )
    }
    
    func toJson() -> AnyObject {
        return [
        "interfaceType" : interfaceType.rawValue,
        "type" : type.toJson(),
        "inherits" : inherits.map { $0.toJson() },
        "modifiers" : modifiers.map { $0.rawValue },
        "properties" : properties.map { $0.toJson() },
        "functions" : functions.map { $0.toJson() },
        "enumCases" : enumCases.map { $0.toJson() },
        "typealiases" : typealiases,
        "serializedAttributes" : serializedAttributes
        ]
    }
}

extension Type : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> Type {
        let type = try Json.deserialize(json, "type") as String
        switch type {
        case "normal":
            return Type.Normal(try Json.deserialize(json, "i"), try Json.deserialize(json, "ga"))
        case "tuple":
            return Type.Tuple(try Json.deserialize(json, "t"))
        case "function":
            return Type.Function(try Json.deserialize(json, "l"), try Json.deserialize(json, "r"))
        default:
            throw NSError(domain: JsonParsingDomain, code: JsonParsingError.WrongType.rawValue, userInfo: nil)
        }
    }
    
    func toJson() -> AnyObject {
        switch self {
        case .Normal(let i, let ga):
            return [
                "type" : "normal",
                "i" : i,
                "ga" : ga.map { $0.toJson() }
            ]
        case .Tuple(let t):
            return [
                "type" : "tuple",
                "t" : t.map { $0.toJson() }
            ]
        case .Function(let l, let r):
            return [
                "type" : "function",
                "l" : l.toJson(),
                "r" : r.toJson()
            ]
        }
    }
}

extension AccessType : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> AccessType {
        return AccessType(rawValue: json as! Int)!
    }
        
    func toJson() -> AnyObject {
        return rawValue
    }
}

extension PropertyMetadata : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> PropertyMetadata {
        return PropertyMetadata(
            name: try Json.deserialize(json, "name"),
            type: try Json.deserialize(json, "type"),
            modifiers: try Json.deserialize(json, "modifiers"),
            accessType: try Json.deserialize(json, "accessType"),
            serializedAttributes: try Json.deserialize(json, "serializedAttributes")
        )
    }
    
    func toJson() -> AnyObject {
        return [
            "name" : name,
            "type" : type.toJson(),
            "modifiers" : modifiers.map { $0.rawValue },
            "accessType" : accessType.rawValue,
            "serializedAttributes" : serializedAttributes
        ]
    }
}

extension FunctionMetadata : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> FunctionMetadata {
        var function = FunctionMetadata(
            name: try Json.deserialize(json, "name"),
            arguments: try Json.deserialize(json, "arguments"),
            returnType: try Json.deserialize(json, "returnType"),
            modifiers: try Json.deserialize(json, "modifiers")
        )
        
        function.serializedAttributes = try Json.deserialize(json, "serializedAttributes")
        
        return function
    }
    
    func toJson() -> AnyObject {
        return [
            "name" : name,
            "arguments" : arguments.map { $0.toJson() },
            "returnType" : returnType.toJson(),
            "modifiers" : modifiers.map { $0.rawValue },
            "serializedAttributes" : serializedAttributes
        ]
    }
}

extension EnumCaseMetadata : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> EnumCaseMetadata {
        var enumCase = EnumCaseMetadata(
            name: try Json.deserialize(json, "name"),
            arguments: try Json.deserialize(json, "arguments"),
            modifiers: try Json.deserialize(json, "modifiers")
        )
        
        enumCase.serializedAttributes = try Json.deserialize(json, "serializedAttributes")
        
        return enumCase
    }
    
    func toJson() -> AnyObject {
        return [
            "name" : name,
            "arguments" : arguments.map { $0.toJson() },
            "modifiers" : modifiers.map { $0.rawValue },
            "serializedAttributes" : serializedAttributes
        ]
    }
}

extension Modifier : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> Modifier {
        return Modifier(rawValue: json as! Int)!
    }
    
    func toJson() -> AnyObject {
        return rawValue
    }
}

extension ArgumentMetadata : JsonConvertable {
    static func parseJson(json: AnyObject) throws -> ArgumentMetadata {
        return ArgumentMetadata(
            name: try Json.deserialize(json, "name"),
            publicName: try Json.deserialize(json, "publicName"),
            type: try Json.deserialize(json, "type")
        )
    }
    
    func toJson() -> AnyObject {
        return [
            "name" : name,
            "publicName" : publicName,
            "type" : type.toJson()
        ]
    }
}