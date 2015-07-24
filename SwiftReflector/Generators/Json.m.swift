//
//  Json.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let JsonParsingDomain = "JSONParsing"

let JsonParsingTargetKey = "JSONParsingTarget"
let JsonParsingTargetPathKey = "JSONParsingTargetPath"

enum JsonParsingError : Int {
    case MemberDoesntExist = 1
    case WrongType = 2
}

protocol JsonConvertable {
    static func parseJson(json: AnyObject) throws -> Self
    func toJson() -> AnyObject
}

extension String : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> String {
        return try castJson(json, path: ".")
    }
}

extension Int : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Int {
        return try castJson(json, path: ".")
    }
}

extension Bool : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Bool {
        return try castJson(json, path: ".")
    }
}

extension Float : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Float {
        return try castJson(json, path: ".")
    }
}

extension Double : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Double {
        return try castJson(json, path: ".")
    }
}

func castJson<T>(json: AnyObject, path: String) throws -> T {
    if let result = json as? T {
        return result
    }
    else {
        throw NSError(
            domain: JsonParsingDomain,
            code: JsonParsingError.WrongType.rawValue,
            userInfo: [
                JsonParsingTargetKey : json,
                JsonParsingTargetPathKey : path
            ])
    }
}

extension Json {

    static func deserialize<T: JsonConvertable>(json: AnyObject) throws -> T {
        return try T.parseJson(json)
    }

    static func valueAtPath(json: AnyObject, _ path: String) throws -> AnyObject? {
        var root: AnyObject = json
        for p in path.componentsSeparatedByString(".") {
            let dictionary: NSDictionary = try castJson(root, path: path)
            
            guard let value = dictionary[p] else {
                return nil
            }
            
            if value as? NSNull != nil {
                return nil
            }
            
            root = value
        }
        
        return root
    }

    static func deserialize<T: JsonConvertable>(json: AnyObject, _ path: String) throws -> T? {
        if let value = try valueAtPath(json, path) {
            return try T.parseJson(value)
        }
        else {
            return nil
        }
    }

    static func deserialize<T: JsonConvertable>(json: AnyObject, _ path: String) throws -> T {
        let result: T? = try deserialize(json, path)
        guard let result2 = result else {
            throw NSError(
                domain: JsonParsingDomain,
                code: JsonParsingError.MemberDoesntExist.rawValue,
                userInfo: [
                    JsonParsingTargetKey: json,
                    JsonParsingTargetPathKey: path
                ])
        }
        
        return result2
    }

    static func deserialize<T: JsonConvertable>(json: AnyObject) throws -> [T] {
        return try [T].parseJson(json)
    }

    static func deserialize<T: JsonConvertable>(json: AnyObject, _ path: String) throws -> [T] {
        if let value = try valueAtPath(json, path) {
            return try [T].parseJson(value)
        }
        else {
            return []
        }
    }

    static func deserialize<T>(json: AnyObject, _ path: String, _ convert: (AnyObject) throws -> T) throws -> [T] {
        guard let target = try valueAtPath(json, path) else {
            return []
        }
        
        let elements: NSArray = try castJson(target, path: path)
        
        var results = [T]()
        
        for e in elements {
            results.append(try convert(e))
        }
        
        return results
        
    }
}

extension Array where Element : JsonConvertable {
    func toJson() -> AnyObject {
        return self.map { $0.toJson() }
    }
    
    static func parseJson(json: AnyObject) throws -> [Element] {
        let elements: NSArray = try castJson(json, path: ".")
        
        var results = [Element]()
        
        for e in elements {
            results.append(try Element.parseJson(e))
        }
        
        return results
    }
}

class JsonAttribute {
    typealias Transform = AnyObject -> AnyObject?
    let path: String?
    let transform: Transform?
    let implementation: String?
    
    init(path: String? = nil, transform: Transform? = nil, implementation: String? = nil) {
        self.path = path
        self.transform = transform
        self.implementation = implementation
    }
}

class Json : CodeGeneratorBase, CodeGeneratorType {
    let implementation: String?
    
    init(implementation: String? = nil) {
        self.implementation = implementation
    }
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        let implementationName: String
        if interfaceMetadata.interfaceType == .Protocol_ {
            if let explicitName = self.implementation {
                implementationName = explicitName
            }
            else {
                file.write("/* Interface implementation not specified, please use `Json(implementation: \"Value\")` for `\(interfaceMetadata.type)` */ ")
                return
            }
        }
        else {
            implementationName = interfaceMetadata.type.description
        }
        
        file.writeln("// Json for \(interfaceMetadata.type)")
        file.writeln("")
        
        let parse = { () -> Void in
                for p in interfaceMetadata.properties {
                    let jsonAttribute = p.attribute() as JsonAttribute?
                    let type: String
                    if let backingType = jsonAttribute?.implementation {
                        type = backingType
                    }
                    else {
                        type = p.type.description
                    }
                    let path = jsonAttribute?.path != nil ? jsonAttribute!.path! : p.name
                    file.writeln("let \(p.name): \(type) = try Json.deserialize(json, \"\(path)\")")
                }
                file.writeln("return \(implementationName)(\n            " + ",\n            ".join(interfaceMetadata.properties.map { "\($0.name): \($0.name)" }) + "\n         )")
        }
        
        let serialize = { () -> Void in
            let optional = "?"
            let ensureNotNil = " ?? NSNull()"
            let empty = ""
            
            file.writeln("return [\n            " + ",\n            ".join(interfaceMetadata.properties.map { p in "\"\(p.name)\" : \(p.name)\(p.type.isOptional ? optional : empty).toJson()\(p.type.isOptional ? ensureNotNil : empty)" }) + "\n         ]")
        }
        
        if interfaceMetadata.interfaceType == .Protocol_ {
            file.writeBlock("extension \(interfaceMetadata.type)") {
                file.writeBlock("func toJson() -> AnyObject") {
                    serialize()
                }
            }
            
            file.writeln("")
            
            file.writeBlock("extension Json") {
                
                file.writeBlock("static func deserialize(json: AnyObject) throws -> \(interfaceMetadata.type)") {
                    parse()
                }
                
                file.writeln("")
                
                file.writeBlock("static func deserialize(json: AnyObject, _ path: String) throws -> \(interfaceMetadata.type)?") {
                    
                    file.writeBlock("if let value = try Json.valueAtPath(json, path)") {
                        file.writeln("return try Json.deserialize(value)")
                    }
                    file.writeBlock("else") {
                        file.writeln("return nil")
                    }
                }
                
                file.writeBlock("static func deserialize(json: AnyObject, _ path: String) throws -> \(interfaceMetadata.type)") {
                    file.writeln("let result: \(interfaceMetadata.type)? = try Json.deserialize(json, path)")
                    file.writeBlock("guard let result2 = result else") {
                        file.writeln("throw NSError(")
                        file.writeln("    domain: JsonParsingDomain,")
                        file.writeln("    code: JsonParsingError.MemberDoesntExist.rawValue,")
                        file.writeln("    userInfo: [")
                        file.writeln("          JsonParsingTargetKey: json,")
                        file.writeln("          JsonParsingTargetPathKey: path")
                        file.writeln("      ])")
                    }
                    
                    file.writeln("return result2")
                }
                
                file.writeBlock("static func deserialize(json: AnyObject, _ path: String) throws ->[\(interfaceMetadata.type)]") {
                    file.writeln("return try Json.deserialize(json, path, Json.deserialize)")
                }
            }
        }
        else {
            file.writeBlock("extension \(implementationName) : JsonConvertable") {
                file.writeBlock("static func parseJson(json: AnyObject) throws -> \(interfaceMetadata.type)") {
                    parse()
                }
                file.writeln("")
                file.writeBlock("func toJson() -> AnyObject") {
                    serialize()
                }
            }
        }
        
    }
}