//
//  Xml.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 8/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class XmlAttribute {
    let path: String?
    let filter: String?
    let deserialize: String?
    let serialize: String?
    let implementation: String?
    
    init(path: String? = nil, filter: String?, deserialize: String? = nil, serialize: String? = nil, implementation: String? = nil) {
        self.path = path
        self.filter = filter
        self.deserialize = deserialize
        self.serialize = serialize
        self.implementation = implementation
    }
}

class Xml : CodeGeneratorBase, CodeGeneratorType {
    let root: String?
    let implementation: String?
    
    init(root: String? = nil, implementation: String? = nil) {
        self.root = root
        self.implementation = implementation
    }
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        let implementationName: String
        if interfaceMetadata.interfaceType == .Protocol_ {
            if let explicitName = self.implementation {
                implementationName = explicitName
            }
            else {
                file.write("/* Interface implementation not specified, please use `Xml(implementation: \"Value\")` for `\(interfaceMetadata.type)` */ ")
                return
            }
        }
        else {
            implementationName = interfaceMetadata.type.description
        }
        
        file.writeln("// Xml for \(interfaceMetadata.type)")
        file.writeln("")
        
        let parse = { () -> Void in
            for p in interfaceMetadata.properties {
                let jsonAttribute = p.attribute() as XmlAttribute?
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
                }) + "\n\nreturn json\n")
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


func a2 () {
    let data = "<a c=\"34\"><B>s</B></a>".dataUsingEncoding(NSUTF8StringEncoding)!
    let document = try! NSXMLDocument(data: data, options: 0)
    let attribute = (document.children![0] as! NSXMLElement).attributes![0]
     //document.children![0].children![0].children![0].kind
}

let XmlParsingDomain = "XMLParsing"

let XmlParsingTargetKey = "XmlParsingTarget"
let XmlParsingTargetPathKey = "XmlParsingTargetPath"

let xPathSelf = ""

enum XmlParsingError : Int {
    case MemberDoesntExist = 1
    case WrongType = 2
    case WrongXPath = 3
}

protocol XmlConvertable {
    static func parseXml(root: NSXMLElement, xPath: String) throws -> Self?
    func toXml(root: NSXMLElement, xPath: String)
}

extension StringSerializable {
    func toXml(root: NSXMLElement, xPath: String) {
        if xPath.hasPrefix("@") {
            let attributeName = xPath.substringFromIndex(xPath.startIndex.successor())
            root.addAttribute(NSXMLNode.attributeWithName(attributeName, stringValue: self.toString()) as! NSXMLNode)
        }
        else if xPath == "text()" {
            root.addChild(NSXMLNode.textWithStringValue(self.toString()) as! NSXMLNode)
        }
        else {
            let value = NSXMLNode.elementWithName("Value", stringValue: self.toString()) as! NSXMLNode
            root.addChild(value)
        }
    }
    
    static func parseXml(root: NSXMLElement, xPath: String) throws -> Self? {
        if xPath.hasPrefix("@") {
            let attributeName = xPath.substringFromIndex(xPath.startIndex.successor())
            guard let stringValue = root.attributeForName(attributeName)?.stringValue else {
                return nil
            }
            
            return try self.parseString(stringValue)
        }
        else if xPath == "text()" {
            guard let stringValue = root.stringValue else {
                return nil
            }
            
            return try self.parseString(stringValue)
        }
        else if xPath == xPathSelf {
            guard let stringValue = root.stringValue else {
                return nil
            }
            
            return try self.parseString(stringValue)
        }
        else {
            let error = { () -> Void in
                throw NSError(domain: XmlParsingDomain, code: XmlParsingError.WrongXPath.rawValue, userInfo: nil)
            }
            try! error()
            return nil
        }
    }
}

extension String : XmlConvertable {
}

extension Int : XmlConvertable {
}

extension Bool : XmlConvertable {
}

extension Float : XmlConvertable {
}

extension Double : XmlConvertable {
}

extension Xml {
    
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

extension NSXMLElement {
    
    func ensureXPathElement(xPath: String) -> NSXMLElement {
        if xPath == xPathSelf {
            return self
        }
     
        var element = self
        for component in xPath.componentsSeparatedByString("/") {
            if let nextElement = element.elementsForName(component).first {
                element = nextElement
                continue
            }

            let newElement = NSXMLElement.elementWithName(component) as! NSXMLElement
            element = newElement
        }
        
        return element
    }
  
    func getXPathElement(xPath: String) -> NSXMLElement? {
        if xPath == xPathSelf {
            return self
        }
        
        let components = xPath.componentsSeparatedByString("/")
        
        var element = self
        for component in components {
            if let nextElement = element.elementsForName(component).first {
                element = nextElement
                continue
            }
            
            return nil
        }
        
        return element
    }
    
    /*
    func getXPathElementAndLastSegment(xPath: String) -> (NSXMLElement?, String?) {
        if xPath == "" {
            return (self, xPathSelf)
        }
        
        let components = xPath.componentsSeparatedByString("/")
        
        var element = self
        for i in 0 ..< components.count - 1 {
            let component = components[i]
            if let nextElement = element.elementsForName(component).first {
                element = nextElement
                continue
            }
            
            return (nil, nil)
        }
        
        return (element, components.last!)
    }*/
}

extension Array where Element : XmlConvertable {
    static func parseXml(root: NSXMLElement, xPath: String) throws -> Array<Element> {
        let whereToReadFrom = root.getXPathElement(xPath)
        
        let nodes = whereToReadFrom?.children ?? []
        
        var results = [Element]()
        
        for e in nodes {
            let node = try castOrThrow(e) as NSXMLElement
            if let element = try Element.parseXml(node, xPath: xPathSelf) {
                results.append(element)
            }
        }
        
        return results
    }
    
    func toXml(root: NSXMLElement, xPath: String) {
        let whereToInsert = root.ensureXPathElement(xPath)
        
        for e in self {
            e.toXml(whereToInsert, xPath: xPathSelf)
        }
    }
}

