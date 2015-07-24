//
//  Implement.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Implement : CodeGeneratorBase, CodeGeneratorType {
    let filePath: String?
    
    init(filePath: String? = nil) {
        self.filePath = filePath
    }
    
    override func pathForGeneratedSourceCode(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> String {
        if let filePath = self.filePath {
            return filePath
        }
        else {
            return super.pathForGeneratedSourceCode(interfaceMetadata, metadata: metadata)
        }
    }
    
    static func implementationNameForInterface(interface: InterfaceMetadata) -> String {
        let name = interface.type.identifier
        if name.hasSuffix("Type") {
            return name.substringToIndex(advance(name.endIndex, -4))
        }
        
        return name + "Implementation"
    }
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        let inherits = ", ".join(interfaceMetadata.inherits.map { "\($0)" })
        let type = interfaceMetadata.type.description
        file.writeBlock("\(interfaceMetadata.interfaceType) \(type) : \(inherits)") {
            for p in interfaceMetadata.properties {
                file.writeln("var \(p.name): \(p.type)")
            }
            file.writeln("")
            let parameters = ", ".join(interfaceMetadata.properties.map { "\($0.name): \($0.type)" })
            file.writeBlock("init(\(parameters))") {
                for p in interfaceMetadata.properties {
                    file.writeln("self.\(p.name) = \(p.name)")
                }
            }
        }
        file.writeln("")
        file.writeBlock("extension \(type) : CustomStringConvertible") {
            file.writeBlock("var description: String") {
                file.writeln("return \"\(type)(\\n\"")
                for (i, p) in interfaceMetadata.properties.enumerate() {
                    let separator = i != interfaceMetadata.properties.count - 1 ? "," : ""
                    file.writeln("    +  \"    \(p.name): \\(prettyDescription(\(p.name)))\(separator)\\n\"")
                }
                file.writeln("    +  \")\"")
            }
        }
        
        /*
        file.writeln("")
        file.writeBlock("func == (lhs: \(type), rhs: \(type)) -> Bool") {
            file.writeln("return " + "\n        && ".join(interfaceMetadata.properties.map { "lhs.\($0.name) == rhs.\($0.name)" }))
        }*/
    }
}