//
//  EqualityExtensions.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Type : Equatable {
    
}

extension InterfaceMetadata : Equatable {
    
}

extension PropertyMetadata : Equatable {
    
}

extension FunctionMetadata : Equatable {
    
}

extension ArgumentMetadata : Equatable {
    
}

extension SourceFile : Equatable {
    
}

extension EnumCaseMetadata : Equatable {
    
}

func ==(lhs: PropertyMetadata, rhs: PropertyMetadata) -> Bool {
    return lhs.name == rhs.name
        && lhs.accessType == rhs.accessType
        && lhs.modifiers == rhs.modifiers
        && lhs.type == rhs.type
        && lhs.serializedAttributes == rhs.serializedAttributes
}

func ==(lhs: InterfaceMetadata, rhs: InterfaceMetadata) -> Bool {
    return lhs.type == rhs.type
        && lhs.modifiers == rhs.modifiers
        && lhs.inherits == rhs.inherits
        && lhs.properties == rhs.properties
        && lhs.serializedAttributes == rhs.serializedAttributes
        && lhs.functions == rhs.functions
        && lhs.enumCases == rhs.enumCases
}

func ==(lhs: EnumCaseMetadata, rhs: EnumCaseMetadata) -> Bool {
    return lhs.name == rhs.name
    && lhs.modifiers == rhs.modifiers
    && lhs.arguments == rhs.arguments
}

func ==(lhs: Type, rhs: Type) -> Bool {
    return lhs.description == rhs.description
}

func ==(lhs: FunctionMetadata, rhs: FunctionMetadata) -> Bool {
    return lhs.arguments == rhs.arguments
        && lhs.description == rhs.description
        && lhs.modifiers == rhs.modifiers
        && lhs.name == rhs.name
        && lhs.returnType == rhs.returnType
        && lhs.serializedAttributes == rhs.serializedAttributes
}

func ==(lhs: ArgumentMetadata, rhs: ArgumentMetadata) -> Bool {
    return lhs.name == rhs.name
        && lhs.publicName == rhs.publicName
        && lhs.type == rhs.type
}

func ==(lhs: SourceFile, rhs: SourceFile) -> Bool {
    return lhs.path == rhs.path
        && lhs.declarations == rhs.declarations
}