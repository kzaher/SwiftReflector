//
//  PropertyMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum AccessType: Int {
    case None = 0
    case Getter = 1
    case Setter = 2
    case GetterAndSetter = 3
}

final class PropertyMetadata {
    var name: String
    var type: Type
    var modifiers: [Modifier]
    var accessType: AccessType
    var serializedAttributes: [String]
    var attributes: [String: AnyObject] = [:]
    
    init(name: String, type: Type, modifiers: [Modifier], accessType: AccessType, serializedAttributes: [String]) {
        self.name = name
        self.type = type
        self.modifiers = modifiers
        self.accessType = accessType
        self.serializedAttributes = serializedAttributes
    }
    
    func attribute<AttributeType : AnyObject>() -> AttributeType? {
        return attributes["\(AttributeType.self)"] as? AttributeType
    }
    
    func registerAttribute(attribute: AnyObject) {
        attributes["\(attribute.dynamicType)"] = attribute
    }
}

extension PropertyMetadata : CustomStringConvertible {
    var description: String {
        let modifiersDescription = " ".join(modifiers.map { "\($0)" })
        return "\(serializedAttributes) \(modifiersDescription) var \(name): \(type) { \(self.accessType) }"
    }
}