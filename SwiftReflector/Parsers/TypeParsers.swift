//
//  TypeParsers.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html#//apple_ref/doc/uid/TP40014097-CH31-ID445

let typeParser = {
    return RecursiveParser<Type> { (recurse) -> ParserOf<Type> in
        
        let commaSpace = begin(spaceOrNewlineParser)
            .then(constant(","))
            .then(spaceOrNewlineParser)
            .parse { () }
        
        // Generic Parser
        let identifier = Name(identifierParser)
        let genericArguments = Name(recurse.zeroPlusSeparatedBy(commaSpace))
        
        let genericArgumentsParser = begin(spaceOrNewlineParser)
            .then(constant("<"))
            .then(spaceOrNewlineParser)
            .then(genericArguments)
            .then(spaceOrNewlineParser)
            .then(constant(">"))
            .parse {
                return genericArguments.value ?? []
            }
            .optional
        
        let genericArguments2 = Name(genericArgumentsParser)
        let typeParser = begin(spaceParser)
            .then(identifier)
            .then(genericArguments2)
            .parse { () -> Type in
                return Type.Normal(identifier.value, genericArguments2.value ?? [])
            }
        //
        
        // Array {
        
        let aRecurse = Name(recurse)
        let arrayParser = begin(spaceOrNewlineParser)
            .then(constant("["))
            .then(spaceOrNewlineParser)
            .then(aRecurse)
            .then(spaceOrNewlineParser)
            .then(constant("]"))
            .parse {
                return Type.Normal("Array", [aRecurse.value])
            }
        
        
        // }
        
        // Dictionary {
        
        let dRecurse1 = Name(recurse)
        let dRecurse2 = Name(recurse)
        let dictionaryParser = begin(spaceOrNewlineParser)
            .then(constant("["))
            .then(spaceOrNewlineParser)
            .then(dRecurse1)
            .then(spaceOrNewlineParser)
            .then(constant(":"))
            .then(spaceOrNewlineParser)
            .then(dRecurse2)
            .then(spaceOrNewlineParser)
            .then(constant("]"))
            .parse {
                return Type.Normal("Dictionary", [dRecurse1.value, dRecurse2.value])
            }
    
        // }
        
        // Tuple {
        
        let t1 = Name(recurse)
        let t2 = Name(recurse.zeroPlusSeparatedBy(commaSpace))
        let tupleParser = begin(spaceOrNewlineParser)
            .then(constant("("))
            .then(spaceOrNewlineParser)
            .then(t1)
            .then(spaceOrNewlineParser)
            .then(constant(","))
            .then(spaceOrNewlineParser)
            .then(t2)
            .then(spaceOrNewlineParser)
            .then(constant(")"))
            .parse { () -> Type in
                var results = t2.value
                results.insert(t1.value, atIndex: 0)
                return Type.Tuple(results)
            }
        
        // }
        
        // Braces {
        
        let bracesType = Name(recurse)
        let bracesParser = begin(spaceOrNewlineParser)
            .then(constant("("))
            .then(spaceOrNewlineParser)
            .then(bracesType)
            .then(spaceOrNewlineParser)
            .then(constant(")"))
            .parse {
                return bracesType.value
            }

        // }

        let beforeOptionalParser = combine(
            typeParser,
            arrayParser,
            dictionaryParser,
            tupleParser,
            bracesParser
        )

        // Optional part {
        let beforeOptional = Name(beforeOptionalParser)
        let optional = Name(constant("?").zeroPlusSeparatedBy(spaceOrNewlineParser))
        let firstPartParser = begin(spaceOrNewlineParser)
            .then(beforeOptional)
            .then(spaceOrNewlineParser)
            .then(optional)
            .parse { () -> Type in
                var type = beforeOptional.value
                let optionalValues: [Void] = optional.value ?? []
                for o in optionalValues {
                    type = Type.Normal("Optional", [type])
                }
                return type
            }
        
        // }
        
        // Function {
        
        let f2 = Name(recurse)
        let secondPart = begin(spaceOrNewlineParser)
            .then(constant("->"))
            .then(spaceOrNewlineParser)
            .then(f2)
            .parse {
                return f2.value
            }
        
        let f1 = Name(firstPartParser)
        let optionalSecond = Name(secondPart.optional)
        let functionParser = begin(spaceOrNewlineParser)
            .then(f1)
            .then(optionalSecond)
            .parse { () -> Type in
                if let second = optionalSecond.value {
                    return Type.Function(f1.value, second)
                }
                else {
                    return f1.value
                }
            }
        
        // }
        
        return functionParser
    }
}()


let returnTypeParser = { () -> ParserOf<Type> in
    let type = Name(typeParser)
    
    let returnValueParser = begin(spaceOrNewlineParser)
        .then(constant("->"))
        .then(spaceOrNewlineParser)
        .then(type)
        .parse { () -> Type in
            return type.value
        }
        .optional
    
    let returnValue = Name(returnValueParser)
    return begin(spaceOrNewlineParser)
        .then(returnValue)
        .parse {
            return returnValue.value ?? Type.void
        }
}()