//
//  Value.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Value : MetadataGeneratorType {
    let implementation: String?
    let filePath: String?
    
    init(implementation: String? = nil, filePath: String? = nil) {
        self.implementation = implementation
        self.filePath = filePath
    }
    
    func generateInterfaces(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> [InterfaceMetadata] {
        let implementation = InterfaceMetadata(interfaceType: InterfaceType.Struct,
            type: Type.Normal(self.implementation ?? Implement.implementationNameForInterface(interfaceMetadata), []),
            inherits: [interfaceMetadata.type],
            modifiers: interfaceMetadata.modifiers,
            properties: interfaceMetadata.properties,
            functions: interfaceMetadata.functions,
            enumCases: interfaceMetadata.enumCases,
            typealiases: interfaceMetadata.typealiases,
            serializedAttributes: interfaceMetadata.serializedAttributes
        )
        implementation.file = interfaceMetadata.file
        implementation.registerAttribute(Implement(filePath: self.filePath))
        
        return [implementation]
    }
}