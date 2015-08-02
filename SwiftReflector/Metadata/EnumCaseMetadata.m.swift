//
//  EnumCaseMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 8/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct EnumCaseMetadata : CustomStringConvertible {
    var name: String
    var arguments: [ArgumentMetadata]
    var modifiers: [Modifier]
    var serializedAttributes: [String]
    
    init(name: String, arguments: [ArgumentMetadata], modifiers: [Modifier]) {
        self.name = name
        self.arguments = arguments
        self.modifiers = modifiers
        self.serializedAttributes = []
    }
    
    var description: String {
        let modifiers = " ".join(self.modifiers.map { "\($0)" })
        let arguments = ", ".join(self.arguments.map { "\($0.name): \($0.type)" })
        return "\(serializedAttributes) \(modifiers) \(name)(\(arguments))"
    }
}