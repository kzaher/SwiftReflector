//
//  MetadataGeneratorType.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol MetadataGeneratorType {
    
    func generateInterfaces(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> [InterfaceMetadata]
    
}