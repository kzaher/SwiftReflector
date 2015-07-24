//
//  IdentifierParsers.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let identifierFirst = { () -> NSCharacterSet in
    let alphaNumeric = NSMutableCharacterSet.letterCharacterSet()
    
    alphaNumeric.addCharactersInString("_")
    
    return alphaNumeric
}()

let identifierOther = { () -> NSCharacterSet in
    let alphaNumeric = NSMutableCharacterSet.alphanumericCharacterSet()
    
    alphaNumeric.addCharactersInString("_")
    
    return alphaNumeric
}()

let identifierParser = ParserOf { p -> [(String, ParsePosition)] in
    var next = p
    var identifier = ""
    
    let doItLater = ""
    
    while true {
        if let character = next.character {
            if (next == p && identifierFirst.longCharacterIsMember(character.value))
                || (next != p && identifierOther.longCharacterIsMember(character.value)) {
                identifier.append(character)
                next = next.next
            }
            else {
                break
            }
        }
        else {
            break
        }
    }
    
    if identifier == "" {
        return []
    }
    return [(identifier, next)]
}