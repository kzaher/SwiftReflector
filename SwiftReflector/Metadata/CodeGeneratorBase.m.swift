//
//  CodeGeneratorBase.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func _increaseIndent(description: String) -> String {
    let descriptionLines = description.componentsSeparatedByString("\n")
    var result = [descriptionLines.first!]
    result += descriptionLines[1 ..< descriptionLines.count].map {
        "        " + $0
    }
    
    return "\n".join(result)
}

func prettyDescription(string: String) -> String {
    let escaped = string.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        .stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
    return "\"\(escaped)\""
}

func prettyDescription<T>(value: T) -> String {
    return _increaseIndent("\(value)")
}

class CodeGeneratorBase {
    
    var suffix: String {
        get {
            var name = "\(self.dynamicType)"
            
            while name.rangeOfString(".") != nil {
                name = name.substringFromIndex(name.rangeOfString(".")!.startIndex.successor())
            }
 
            return name
        }
    }
    
    /*class func defaultImplementationNameForInterface(interfaceMetadata: InterfaceMetadata, moduleMetadata: ModuleMetadataType) -> String? {
        if interfaceMetadata.interfaceType != .Protocol_ {
            return interfaceMetadata.type.description
        }
        
        let interfaceName = interfaceMetadata.type.name
        if interfaceName.hasSuffix("Type") {
            return interfaceName.substringToIndex(advance(interfaceName.endIndex, -4))
        }
        else {
            if let value = moduleMetadata.attributeForInterface(interfaceMetadata) as Value? {
                let implementation = value.generateInterfaces().first!
                return implementation.type.description
            }
            else if let classAttribute = moduleMetadata.attributeForInterface(interfaceMetadata) as Class? {
                let implementation = classAttribute.generateInterfaces().first!
                return implementation.type.description

            }
            else {
                return nil
            }
        }
    }*/
    
    func pathForGeneratedSourceCode(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> String {
        return interfaceMetadata.file.path.stringByReplacingOccurrencesOfString(".r.", withString: "." + suffix + ".")
    }
    
}