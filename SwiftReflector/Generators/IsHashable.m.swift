//
//  IsHashable.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class IsHashable : IsEquatable {
    override init() {
        super.init()
    }
    
    override func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        super.write(interfaceMetadata, metadata: metadata, file: file)
        
        let name = interfaceMetadata.type.description
        file.writeln("// Hashable \(name)")
        file.writeln("")
        let inherits = interfaceMetadata.interfaceType != .Protocol_ ? " : Hashable" : ""
        file.writeBlock("extension \(name) \(inherits)") {
            file.writeBlock("var hashValue: Int") {
                file.writeln("return " + "\n        ^ ".join(interfaceMetadata.properties.map { "\($0.name).hashValue" }))
            }
        }
        file.writeln("")
    }
}