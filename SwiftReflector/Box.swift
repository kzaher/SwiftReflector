//
//  Box.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/16/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

class MutableBox<T> {
    var value: T
    
    init(_ value: T) {
        self.value = value
    }
}

extension Box : CustomStringConvertible {
    var description: String {
        get {
            return "\(self.value)"
        }
    }
}

extension MutableBox : CustomStringConvertible {
    var description: String {
        get {
            return "\(self.value)"
        }
    }
}