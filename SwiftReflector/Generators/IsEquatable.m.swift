//
//  IsEquatable.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class IsEquatable : CodeGeneratorBase, CodeGeneratorType {
    override init() {
    }
    
    func generateInterfaces() -> [InterfaceMetadata] {
        return []
    }
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        
        let name = interfaceMetadata.type.identifier
        file.writeln("// Equatable \(name)")
        file.writeln("")
        let inherits = interfaceMetadata.interfaceType != .Protocol_ ? " : Equatable" : ""
        file.writeBlock("extension \(name) \(inherits)") {
        }
        
        file.writeln("")
        file.writeBlock("func == (lhs: \(name), rhs: \(name)) -> Bool") {
            file.writeln("return " + "\n        && ".join(interfaceMetadata.properties.map { "lhs.\($0.name) == rhs.\($0.name)" }))
        }
        
        file.writeln("")
    }
}