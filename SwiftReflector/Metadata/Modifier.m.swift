//
//  Modifier.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum Modifier : Int {
    case Public = 1
    case Private = 2
    case Final = 3
    case Static = 4
    case Class = 5
    case Override = 6
    case Required = 7
    case Dynamic = 8
}

extension Modifier : CustomStringConvertible {
    var description: String {
        get {
            switch self {
            case Public:
                return "public"
            case Private:
                return "private"
            case Final:
                return "final"
            case Static:
                return "static"
            case Class:
                return "class"
            case Override:
                return "override"
            case Required:
                return "required"
            case Dynamic:
                return "dynamic"
            }
        }
    }
}