//
//  FunctionMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct FunctionMetadata : CustomStringConvertible {
    var name: String
    var arguments: [ArgumentMetadata]
    var returnType: Type
    var modifiers: [Modifier]
    var serializedAttributes: [String]
    
    init(name: String, arguments: [ArgumentMetadata], returnType: Type, modifiers: [Modifier]) {
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.modifiers = modifiers
        self.serializedAttributes = []
    }
    
    var description: String {
        let modifiers = " ".join(self.modifiers.map { "\($0)" })
        let arguments = ", ".join(self.arguments.map { "\($0.name): \($0.type)" })
        let returnValues = " -> \(self.returnType)"
        return "\(serializedAttributes) \(modifiers) func \(name)(\(arguments))\(returnValues)"
    }
}