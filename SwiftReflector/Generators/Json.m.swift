//
//  Json.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class JsonAttribute {
    let path: String?
    let deserialize: String?
    let serialize: String?
    let jsonValue: String?
    let implementation: String?
    
    init(path: String? = nil, deserialize: String? = nil, serialize: String? = nil, jsonValue: String? = nil, implementation: String? = nil) {
        self.path = path
        self.deserialize = deserialize
        self.serialize = serialize
        self.implementation = implementation
        self.jsonValue = jsonValue
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
                    let howToDeserialize: String
                    
                    if let deserialize = jsonAttribute?.deserialize {
                        howToDeserialize = " try \(deserialize)(Json.valueAtPath(json, \"\(path)\"))"
                    }
                    else {
                        howToDeserialize = " try Json.deserialize(json, \"\(path)\")"
                    }
                    file.writeln("let \(p.name): \(type) = \(howToDeserialize)")
                }
                file.writeln("return \(implementationName)(\n            " + ",\n            ".join(interfaceMetadata.properties.map { "\($0.name): \($0.name)" }) + "\n         )")
        }
        
        let serialize = { () -> Void in
            file.writeln("let json = NSMutableDictionary()\n        " + "\n        ".join(interfaceMetadata.properties.map { p in
                let jsonAttribute = p.attribute() as JsonAttribute?
                let optional = p.type.isOptional ? "?" : ""
                return "Json.setJsonValueAtPath(json, \"\(jsonAttribute?.path ?? p.name)\",  \(p.name)\(optional).toJson())"
            }) + "\n\n        return json\n")
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
        return try castJson(json)
    }
}

extension Int : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Int {
        return try castJson(json)
    }
}

extension Bool : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Bool {
        return try castJson(json)
    }
}

extension Float : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Float {
        return try castJson(json)
    }
}

extension Double : JsonConvertable {
    func toJson() -> AnyObject {
        return self
    }
    
    static func parseJson(json: AnyObject) throws -> Double {
        return try castJson(json)
    }
}

func castJson<T>(json: AnyObject) throws -> T {
    if let result = json as? T {
        return result
    }
    else {
        throw NSError(
            domain: JsonParsingDomain,
            code: JsonParsingError.WrongType.rawValue,
            userInfo: [
                JsonParsingTargetKey : json,
            ])
    }
}

extension Json {

    static func deserialize<T: JsonConvertable>(json: AnyObject) throws -> T {
        return try T.parseJson(json)
    }

    static func valueAtPath(json: AnyObject, _ path: String) throws -> AnyObject? {
        var root: AnyObject = json
        do {
            for p in path.componentsSeparatedByString(".") {
                let dictionary: NSDictionary = try castJson(root)
                
                guard let value = dictionary[p] else {
                    return nil
                }
                
                if value as? NSNull != nil {
                    return nil
                }
                
                root = value
            }
        }
        catch let error {
            throw NSError(
                domain: JsonParsingDomain,
                code: JsonParsingError.WrongType.rawValue,
                userInfo: [
                    NSLocalizedDescriptionKey: "There was a problem on `\(path)`",
                    NSUnderlyingErrorKey: error as NSError
                ])
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
        
        let elements: NSArray = try castJson(target)
        
        var results = [T]()
        
        for e in elements {
            results.append(try convert(e))
        }
        
        return results
    }
    
    static func setJsonValueAtPath(_json: NSMutableDictionary, _ path: String, _ value: AnyObject?) {
        var json = _json
        let components = path.componentsSeparatedByString(".")
        for i in 0 ..< components.count - 1 {
            let component = components[i]
            if let nextJson = json[component] as? NSMutableDictionary {
                json = nextJson
            }
            else {
                let nextJson = NSMutableDictionary()
                json[component] = nextJson
                json = nextJson
            }
        }
     
        json[components.last!] = value ?? NSNull()
    }
}

extension Array where Element : JsonConvertable {
    func toJson() -> AnyObject {
        return self.map { $0.toJson() }
    }
    
    static func parseJson(json: AnyObject) throws -> [Element] {
        let elements: NSArray = try castJson(json)
        
        var results = [Element]()
        
        for e in elements {
            results.append(try Element.parseJson(e))
        }
        
        return results
    }
}

