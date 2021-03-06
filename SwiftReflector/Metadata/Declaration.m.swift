//
//  Declaration.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum Declaration
{
    case Import(module: String)
    case Interface(interface: InterfaceMetadata)
}

extension Declaration : Equatable, CustomStringConvertible {
    var description: String {
        switch self {
        case .Import(let module):
            return "import \(module)"
        case .Interface(let interface):
            return interface.description
        }
    }
}

func ==(lhs: Declaration, rhs: Declaration) -> Bool {
    switch (lhs, rhs) {
    case (.Import(let module1), .Import(let module2)):
        return module1 == module2
    case (.Interface(let interface1), .Interface(let interface2)):
        return interface1 == interface2
    default:
        return false
    }
}
