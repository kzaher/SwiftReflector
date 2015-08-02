//
//  CoreData.r.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 8/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

//{ Xml() }
enum CoreDataType {
    case String
    case Date
    case Boolean
}

//{ Xml() }
enum CoreDataDeletionRule {
    case Nullify
}

//{ Class(implementation: "CoreDataModelImpl") }
//{ Xml(implementation: "CoreDataModelImpl", root="model") }
protocol CoreDataModel {
    var userDefinedModelVersionIdentifier: String { get set }
    var type: String { get set }
    var documentVersion: String { get set }
    var lastSavedToolsVersion: String { get set }
    var systemVersion: String { get set }
    var minimumToolsVersion: String { get set }
    
    //{ XmlAttribute(path: "") }
    var entities: [CoreDataEntity] { get set }
    
    var elements: [CoreDataElement] { get set }
}

//{ Class(implementation: "CoreDataElementImpl") }
//{ Xml(implementation: "CoreDataElementImpl", root="element") }
protocol CoreDataElement {
    var name: String { get set }
    
    var positionX: Float { get set }
    
    var positionY: Float { get set }
    
    var width: Float { get set }
    
    var height: Float { get set }
}

//{ Class(implementation: "CoreDataEntityImpl") }
//{ Xml(implementation: "CoreDataEntityImpl", root="entity") }
protocol CoreDataEntity {
    var name: String { get set }
    //{ CoreDataBool() }
    var syncable: Bool { get set }
    
    //{ XmlElement(path: "") }
    var attributes: [CoreDataAttribute] { get set }
    
    //{ XmlElement(path: "") }
    var relationships: [CoreDataRelationship] { get set }
}

//{ Class(implementation: "CoreDataAttributeImpl") }
//{ Xml(implementation: "CoreDataAttributeImpl", root="attribute") }
protocol CoreDataAttribute {
    var name: String { get set }
    //{ CoreDataBool() }
    var optional: Bool { get set }
    //{ CoreDataBool() }
    var attributeType: Bool { get set }
    
    var defaultValueString: String { get set }
    
    //{ CoreDataBool() }
    var syncable: Bool { get set }
}

//{ Class(implementation: "CoreDataRelationshipImpl") }
//{ Xml(implementation: "CoreDataRelationshipImpl", root="relationship") }
protocol CoreDataRelationship {
    
    var name: String { get set }
    
    var optional: String { get set }
    
    var maxCount: Int { get set }
    
    var deletionRule: CoreDataDeletionRule { get set }
    
    var destinationEntity: String { get set }
    
    var inverseName: String { get set }
    
    var inverseEntity: String { get set }
    
    //{ CoreDataBool() }
    var syncable: Bool { get set }
}

func convertToCoreDataBool(bool: Bool, _ root: NSXMLElement, _ xPath: String) {
    let attributeName = xPath.substringFromIndex(xPath.startIndex.successor())
    
    let value = NSXMLNode.attributeWithName(attributeName, stringValue: bool ? "YES" : "NO") as! NSXMLNode
    root.insertChild(value, atIndex: root.childCount)
}

func convertFromCoreDataBool(root: NSXMLElement, _ xPath: String) -> Bool {
    let attributeName = xPath.substringFromIndex(xPath.startIndex.successor())
    
    return root.attributeForName(attributeName)?.stringValue ?? "NO" ==  "YES"
}

class CoreDataBool : XmlAttribute {
    init() {
        super.init(path: nil, filter: nil, deserialize: "convertFromCoreDataBool", serialize: "convertToCoreDataBool", implementation: nil)
    }
}