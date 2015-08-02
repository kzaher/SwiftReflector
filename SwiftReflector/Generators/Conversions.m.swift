//
//  Conversions.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 8/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let StringConversionDomain = "StringConversion"
let ConversionError = "ConversionError"

enum StringConversionError : Int {
    case StringConversionFailed = 0
}

func castOrThrow<T>(object: AnyObject) throws -> T {
    if let result = object as? T {
        return result
    }
    else {
        throw NSError(
            domain: ConversionError,
            code: 0,
            userInfo: nil
        )
    }
}

let stringConversionError = NSError(domain: StringConversionDomain, code: StringConversionError.StringConversionFailed.rawValue, userInfo: nil)

protocol StringSerializable {
    static func parseString(string: String) throws -> Self
    func toString() -> String
}

extension String : StringSerializable {
    func toString() -> String {
        return self
    }
    
    static func parseString(string: String) throws -> String {
        return string
    }
}

extension Int : StringSerializable {
    func toString() -> String {
        return self.description
    }
    
    static func parseString(string: String) throws -> Int {
        let maybeValue = Int(string)
        
        guard let value = maybeValue else {
            throw stringConversionError
        }
        
        return value
    }
}

extension Bool : StringSerializable {
    func toString() -> String {
        if self {
            return "true"
        }
        else {
            return "false"
        }
    }
    
    static func parseString(string: String) throws -> Bool {
        switch string {
        case "true":
            return true
        case "1":
            return true
        case "YES":
            return true
        case "false":
            return false
        case "0":
            return false
        case "NO":
            return false
        default:
            throw stringConversionError
        }
    }
}

extension Float : StringSerializable {
    func toString() -> String {
        return self.description
    }
    
    static func parseString(string: String) throws -> Float {
        let maybeValue = Float(string)
        
        guard let value = maybeValue else {
            throw stringConversionError
        }
        
        return value
    }
}

extension Double : StringSerializable {
    func toString() -> String {
        return self.description
    }
    
    static func parseString(string: String) throws -> Double {
        let maybeValue = Double(string)
        
        guard let value = maybeValue else {
            throw stringConversionError
        }
        
        return value
    }
}