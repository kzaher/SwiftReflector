//
//  CodeGenerator.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol CodeGeneratorType {
    
    func pathForGeneratedSourceCode(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> String
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle)
    
}