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
    let publicName: String
    let type: Type
    
    init(name: String, type: Type) {
        self.init(name: name, publicName: name, type: type)
    }
    
    init(name: String, publicName: String, type: Type) {
        self.name = name
        self.publicName = publicName
        self.type = type
    }
}
