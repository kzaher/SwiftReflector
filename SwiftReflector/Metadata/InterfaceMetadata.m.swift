//
//  InterfaceMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum InterfaceType : Int {
    case Protocol_ = 0 // swift compiler :(
    case Class = 1
    case Struct = 2
    case Extension = 3
    case Enum = 4
}

extension InterfaceType : CustomStringConvertible {
    var description: String {
        switch self {
        case Protocol_: return "protocol"
        case Class: return "class"
        case Struct: return "struct"
        case Extension: return "extension"
        case Enum: return "enum"
        }
    }
}

final class InterfaceMetadata {
    var interfaceType: InterfaceType
    
    var type: Type
    var inherits: [Type]
    var modifiers: [Modifier]
    
    var properties: [PropertyMetadata]
    var functions: [FunctionMetadata]
    var enumCases: [EnumCaseMetadata]
    
    var typealiases: [String]
    
    var serializedAttributes: [String]
    
    var attributes: [String: AnyObject] = [:]
    
    var file: SourceFile! = nil
    
    init(
        interfaceType: InterfaceType,
        type: Type,
        inherits: [Type],
        modifiers: [Modifier],
        properties: [PropertyMetadata],
        functions: [FunctionMetadata],
        enumCases: [EnumCaseMetadata],
        typealiases: [String],
        serializedAttributes: [String]
        ) {
            self.interfaceType = interfaceType
            self.type = type
            self.inherits = inherits
            self.modifiers = modifiers
            self.properties = properties
            self.functions = functions
            self.enumCases = enumCases
            self.typealiases = typealiases
            self.serializedAttributes = serializedAttributes
    }
    
    func attribute<AttributeType : AnyObject>() -> AttributeType? {
        return attributes["\(AttributeType.self)"] as? AttributeType
    }
    
    func registerAttribute(attribute: AnyObject) {
        attributes["\(attribute.dynamicType)"] = attribute
    }
    
}

extension InterfaceMetadata : CustomStringConvertible {
    var description : String {
        return "{    interfaceType : \(interfaceType),\n    attributes : \(serializedAttributes),\n    type : \(type),\n    modifiers : \(modifiers),\n    properties : \(properties)\n    functions : \(functions)\n    inherits : \(inherits),\n    enumCases : \(enumCases),\n}"
    }
}