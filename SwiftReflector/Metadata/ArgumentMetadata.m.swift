//
//  ArgumentMetadata.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct ArgumentMetadata {
    let name: String
    let type: Type
    
    init(name: String, type: Type) {
        self.name = name
        self.type = type
    }
}
