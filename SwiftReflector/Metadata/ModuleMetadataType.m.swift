//
//  ModuleMetadataType.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol ModuleMetadataType {
    
    func allInterfaces() -> [InterfaceMetadata]
    
    func interfaceForType(type: Type) -> InterfaceMetadata?
    
}