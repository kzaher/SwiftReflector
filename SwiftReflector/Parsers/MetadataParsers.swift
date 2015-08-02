//
//  MetadataParsers.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let SwiftReflectorDomain = "SwiftReflector"

let SwiftReflectorErrorFarthestKey: NSString = "SwiftReflectorFarthest"
let SwiftReflectorErrorParsedDeclarationsKey: NSString = "SwiftReflectorDeclarations"

enum SwiftReflectorError : Int {
    case ParseError = 1
    case Ambiguous = 2
}

let spaceParser = { () -> ParserOf<Void> in
    return ParserOf { p in
        var next = p
        while next.character == " " {
            next = next.next
        }
        
        return [((), next)]
    }
}()

let spaceOrNewlineParser = { () -> ParserOf<Void> in
    return ParserOf { p in
        var next = p
        while next.character == " " || next.character == "\n" {
            next = next.next
        }
        
        return [((), next)]
    }
}()

let modifierParser = { () -> ParserOf<Modifier> in
    let publicParser = constant("public", value: Modifier.Public)
    let privateParser = constant("private", value: Modifier.Private)
    let finalParser = constant("final", value: Modifier.Final)
    let staticParser = constant("static", value: Modifier.Static)
    //let classParser = constant("class", value: Modifier.Class)
    let overrideParser = constant("override", value: Modifier.Override)
    let requiredParser = constant("required", value: Modifier.Required)
    let dynamicParser = constant("dynamic", value: Modifier.Dynamic)
    
    return combine(
        publicParser,
        privateParser,
        finalParser,
        staticParser,
        //classParser,
        overrideParser,
        requiredParser,
        dynamicParser
    )
}()

let modifiersParser =  { () -> ParserOf<[Modifier]> in
    let modifier = Name(modifierParser)
    
    return modifierParser.zeroPlusSeparatedBy(spaceParser)
}()

let inheritanceParser = { () -> ParserOf<[Type]> in
    // it's more general then necessary, but we don't care
    let separator = combine(
        constant(","),
        constant(":")
    )
    
    let type = Name(typeParser)
    
    return begin(spaceOrNewlineParser)
        .then(separator)
        .then(spaceOrNewlineParser)
        .then(type)
        .then(spaceOrNewlineParser)
        .parse {
            return type.value
        }
        .zeroPlus
}()

// This can obviously fail in some cases, but it's good enough
// It assumes somebody else has parsed first opening `{`
let parseAndIgnoreBody = { () -> ParserOf<Void> in
    return ParserOf { p in
        var left = 1
        
        var next = p
        
        while next.character != nil {
            let character = next.character
            if character == "{" {
                left += 1
            }
            else if character == "}" {
                left -= 1
            }
            
            next = next.next

            if left == 0 {
                return [((), next)]
            }
        }
        
        return []
    }
}()

let readWriteAccessParser = { () -> ParserOf<AccessType> in
    let justReadTheBody = begin(constant("{"))
        .then(parseAndIgnoreBody)
        .parse {
            AccessType.Getter
        }
    
    let body = begin(spaceOrNewlineParser)
        .then(constant("{"))
        .then(parseAndIgnoreBody)
        .parse {
            ()
        }
    
    let getterOrSetter = Name(combine(
        constant("get", value: AccessType.Getter),
        constant("set", value: AccessType.Setter)
    ))
    
    let explicitGetterOrSetterParser = begin(spaceOrNewlineParser)
        .then(getterOrSetter)
        .then(body.optional)
        .parse {
            return getterOrSetter.value
        }
    
    let explicitGetterOrSetter = Name(explicitGetterOrSetterParser.zeroPlus)
    
    let explicitGettersAndSettersParser = begin(spaceOrNewlineParser)
        .then(constant("{"))
        .then(spaceOrNewlineParser)
        .then(explicitGetterOrSetter)
        .then(spaceOrNewlineParser)
        .then(constant("}"))
        .parse { () -> AccessType in
            let hasGetter = explicitGetterOrSetter.value.contains(AccessType.Getter)
            let hasSetter = explicitGetterOrSetter.value.contains(AccessType.Setter)
            var access = 0
            if hasGetter {
                access |= AccessType.Getter.rawValue
            }
            if hasSetter {
                access |= AccessType.Setter.rawValue
            }
            return AccessType(rawValue: access) ?? AccessType.Getter
        }
    
    return first(
        explicitGettersAndSettersParser,
        justReadTheBody,
        constant("", value: AccessType.GetterAndSetter)
    )
}()

let propertyParser = { () -> ParserOf<PropertyMetadata> in
    //let modifiers = Name(modifiersParser)
    let modifiers = Name(modifiersParser)
    let identifier = Name(identifierParser)
    let type = Name(typeParser)
    let readWriteAccess = Name(readWriteAccessParser)
    
    return begin(spaceOrNewlineParser)
        .then(modifiers)
        .then(spaceOrNewlineParser)
        .then(combine(constant("var"), constant("let")))
        .then(spaceOrNewlineParser)
        .then(identifier)
        .then(spaceOrNewlineParser)
        .then(constant(":"))
        .then(spaceOrNewlineParser)
        .then(type)
        .then(spaceOrNewlineParser)
        .then(readWriteAccess)
        .parse {
            return PropertyMetadata(name: identifier.value, type: type.value, modifiers: modifiers.value, accessType: readWriteAccess.value, serializedAttributes: [])
        }
}()

let argumentsParser = { () -> ParserOf<[ArgumentMetadata]> in
    let publicIdentifier = Name(identifierParser)
    let argumentIdentifier = Name(identifierParser.optional)
    let argumentType = Name(typeParser)
    
    let argument = begin(spaceOrNewlineParser)
        .then(publicIdentifier)
        .then(spaceOrNewlineParser)
        .then(argumentIdentifier)
        .then(spaceOrNewlineParser)
        .then(constant(":"))
        .then(spaceOrNewlineParser)
        .then(argumentType)
        .then(spaceOrNewlineParser)
        .parse {
            return ArgumentMetadata(name: argumentIdentifier.value ?? publicIdentifier.value, publicName: publicIdentifier.value,  type: argumentType.value)
        }
    
    
    return argument.zeroPlusSeparatedBy(constant(","))
}()

let functionParser = { () -> ParserOf<FunctionMetadata> in
    
    let modifiers = Name(modifiersParser)
    let name = Name(identifierParser)
    let arguments = Name(argumentsParser)
    let returnType = Name(returnTypeParser)
    
    let bodyParser = begin(spaceOrNewlineParser)
        .then(constant("{"))
        .then(parseAndIgnoreBody)
        .parse {
            ()
        }
    
    let normalFunction = begin(spaceOrNewlineParser)
        .then(constant("func"))
        .then(spaceOrNewlineParser)
        .then(name)
        .parse {
            return name.value
        }
    
    let initFunction = begin(spaceOrNewlineParser)
        .then(constant("init"))
        .then(constant("?").optional)
        .then(spaceOrNewlineParser)
        .parse {
            return "init"
        }
    
    let deinitFunction = begin(spaceOrNewlineParser)
        .then(constant("deinit"))
        .then(spaceOrNewlineParser)
        .then(bodyParser)
        .parse { () -> FunctionMetadata in
            return FunctionMetadata(name: "deinit", arguments: [], returnType: Type.void, modifiers: [])
        }
    
    let name2 = Name(combine(normalFunction, initFunction))
    
    let normalOrInit = begin(spaceOrNewlineParser)
        .then(modifiers)
        .then(name2)
        .then(spaceOrNewlineParser)
        .then(constant("("))
        .then(arguments)
        .then(constant(")"))
        .then(returnType)
        .then(bodyParser.optional)
        .parse { () -> FunctionMetadata in
            return FunctionMetadata(name: name2.value, arguments: arguments.value, returnType: returnType.value, modifiers: modifiers.value)
        }
    
    return combine(normalOrInit, deinitFunction)
}()

let enumCaseParser = { () -> ParserOf<EnumCaseMetadata> in
    let allArguments = Name(argumentsParser)
    
    let optionalArguments = begin(spaceOrNewlineParser)
        .then(constant("("))
        .then(allArguments)
        .then(constant(")"))
        .parse {
            return allArguments.value
        }
        .optional
    
    let modifiers = Name(modifiersParser)
    let name = Name(identifierParser)
    let arguments = Name(optionalArguments)
    
    return begin(spaceOrNewlineParser)
        .then(modifiers)
        .then(spaceOrNewlineParser)
        .then(constant("case"))
        .then(spaceOrNewlineParser)
        .then(name)
        .then(spaceOrNewlineParser)
        .then(arguments)
        .parse {
            return EnumCaseMetadata(name: name.value, arguments: arguments.value ?? [], modifiers: modifiers.value)
        }
}()

enum Member {
    case Comment(string: String)
    case Typealias(name: String)
    case Property(property: PropertyMetadata)
    case Function(function: FunctionMetadata)
    case EnumCase(enumCase: EnumCaseMetadata)
}

let interfaceBodyParser = { () -> ParserOf<[Member]> in
    let singleLineComment = Name(singleLineCommentParser)
    let commentParser = begin(spaceOrNewlineParser)
        .then(singleLineComment)
        .parse {
            return Member.Comment(string: singleLineComment.value)
        }
    
    let typealiasName = Name(identifierParser)
    
    let typealiasParser = begin(spaceOrNewlineParser)
        .then(constant("typealias"))
        .then(spaceOrNewlineParser)
        .then(typealiasName)
        .parse {
            return Member.Typealias(name: typealiasName.value)
        }
    
    return combine(
        commentParser,
        typealiasParser,
        enumCaseParser.map { r, _ ,_ in Member.EnumCase(enumCase: r) },
        propertyParser.map { r, _, _ in Member.Property(property: r) },
        functionParser.map { r, _, _ in Member.Function(function: r) }
    ).zeroPlus
}()


func extractAttribute(comment: String) -> String? {
    let closureExtractor = begin(constant("{"))
        .then(parseAndIgnoreBody)
        .parse {
            ()
        }
        .parsedSubstring
    
    let farthestPosition = MutableBox<ParsePosition!>(nil)
    
    let position = ParsePosition(atStart: comment, farthestPosition: farthestPosition)
    
    if let parsed = closureExtractor.parseAt(position).first?.0 {
        let withoutBraces = parsed.substringToIndex(parsed.endIndex.predecessor()).substringFromIndex(parsed.startIndex.successor())
        return withoutBraces.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    else {
        return nil
    }
}

let interfaceParser = { () -> ParserOf<InterfaceMetadata> in
    let modifiers = Name(modifiersParser)
    
    let interfaceType = Name(combine(
        constant("class", value: InterfaceType.Class),
        constant("struct", value: InterfaceType.Struct),
        constant("protocol", value: InterfaceType.Protocol_),
        constant("extension", value: InterfaceType.Extension),
        constant("enum", value: InterfaceType.Enum)
    ))
    
    let type = Name(typeParser)
    
    let inheritance = Name(inheritanceParser)
    
    let members = Name(interfaceBodyParser)

    return begin(spaceOrNewlineParser)
        .then(modifiers)
        .then(spaceOrNewlineParser)
        .then(interfaceType)
        .then(spaceOrNewlineParser)
        .then(type)
        .then(inheritance)
        .then(spaceOrNewlineParser)
        .then(constant("{"))
        .then(spaceOrNewlineParser)
        .then(members)
        .then(spaceOrNewlineParser)
        .then(constant("}"))
        .parse { () -> InterfaceMetadata in
            var attributes = [String]()
            
            var properties = [PropertyMetadata]()
            var functions = [FunctionMetadata]()
            var enumCases = [EnumCaseMetadata]()
            
            for member in members.value {
                switch member {
                case .Comment(let comment):
                    if let attribute = extractAttribute(comment) {
                        attributes.append(attribute)
                    }
                case .Typealias(let name):
                    attributes.removeAll(keepCapacity: true)
                    break
                case .Property(let property):
                    var property2 = property
                    property2.serializedAttributes = attributes
                    attributes.removeAll(keepCapacity: true)
                    properties.append(property2)
                case .Function(let function):
                    var function2 = function
                    function2.serializedAttributes = attributes
                    attributes.removeAll(keepCapacity: true)
                    functions.append(function2)
                case .EnumCase(let enumCase):
                    var enumCase2 = enumCase
                    enumCase2.serializedAttributes = attributes
                    enumCases.append(enumCase2)
                    attributes.removeAll(keepCapacity: true)
                    
                }
            }
            
            let interfaceMetadata = InterfaceMetadata(
                    interfaceType: interfaceType.value,
                    type: type.value,
                    inherits: inheritance.value,
                    modifiers: modifiers.value,
                    properties: properties,
                    functions: functions,
                    enumCases: enumCases,
                    typealiases: [],
                    serializedAttributes: []
                )
            
            return interfaceMetadata
        }
}()

let restOfLineParser = {
    return begin(not("\n").zeroPlus)
        .then(constant("\n"))
        .parse {
            ()
        }
}()

let singleLineCommentParser = { () -> ParserOf<String> in
    let comment = Name(restOfLineParser.parsedSubstring)
    return begin(spaceOrNewlineParser)
        .then(constant("//"))
        .then(comment)
        .parse {
            return comment.value
        }
}()

let typealiasParser = {
    return begin(spaceOrNewlineParser)
        .then(constant("typealias"))
        .then(restOfLineParser)
        .parse { () }
}()

let definitionParser = {
    return begin(spaceParser)
        .then(constant("let"))
        .then(restOfLineParser)
        .parse { () }
}()

enum ParsedDeclaration {
    case Import(module: String)
    case Comment(comment: String)
    case Typealias
    case Interface(interface: InterfaceMetadata)
    case Function(function: FunctionMetadata)
}

extension ParsedDeclaration : CustomStringConvertible {
    var description: String {
        switch self {
        case .Import(let module):
            return "import \(module)"
        case .Comment(let comment):
            return comment
        case .Typealias:
            return "typealias"
        case .Interface(let interface):
            return "\(interface)"
        case .Function(let function):
            return "\(function)"
        }
    }
}

let importParser = { () -> ParserOf<String> in
    let module = Name(identifierParser)
    return begin(spaceOrNewlineParser)
        .then(constant("import"))
        .then(spaceParser)
        .then(module)
        .then(restOfLineParser)
        .parse {
            return module.value
        }
}()

let fileParser = { () -> ParserOf<[ParsedDeclaration]> in
    
    let declaration = combine(
        functionParser.map { f, _, _ in ParsedDeclaration.Function(function: f) },
        importParser.map { m, _, _ in ParsedDeclaration.Import(module: m) },
        singleLineCommentParser.map { c, _, _ in ParsedDeclaration.Comment(comment: c) },
        typealiasParser.map { _, _, _ in ParsedDeclaration.Typealias },
        interfaceParser.map { i, _, _ in ParsedDeclaration.Interface(interface: i) }
    )
    
    let declarations = Name(declaration.zeroPlus)
    
    return begin(spaceOrNewlineParser)
        .then(declarations)
        .then(spaceOrNewlineParser)
        .parse {
            return declarations.value
        }
}()

func parseFile(content: String) throws -> [Declaration] {
    let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
    let startPosition = ParsePosition(atStart: content, farthestPosition: farthestPosition)
    
    let results = fileParser.parseAt(startPosition)
    
    if results.count == 0 {
        throw NSError(
            domain: SwiftReflectorDomain,
            code: SwiftReflectorError.ParseError.rawValue,
            userInfo: [SwiftReflectorErrorFarthestKey : Box(farthestPosition.value)]
        )
    }
    else if results.count > 1 {
        throw NSError(
            domain: SwiftReflectorDomain,
            code: SwiftReflectorError.Ambiguous.rawValue,
            userInfo: [SwiftReflectorErrorParsedDeclarationsKey : Box(results)]
        )
    }
    
    let (declarations, position) = results[0]
    
    if position.characterIndex != position.characterView.value.endIndex {
        throw NSError(
            domain: SwiftReflectorDomain,
            code: SwiftReflectorError.ParseError.rawValue,
            userInfo: [SwiftReflectorErrorFarthestKey : Box(farthestPosition.value)]
        )
    }
    
    var attributes = [String]()
    
    var interfaces = [Declaration]()
    
    for declaration in declarations {
        switch declaration {
        case .Comment(let comment):
            if let attribute = extractAttribute(comment) {
                attributes.append(attribute)
            }
        case .Interface(let interface):
            interface.serializedAttributes = attributes
            attributes.removeAll()
            interfaces.append(Declaration.Interface(interface: interface))
        case .Typealias:
            attributes.removeAll()
        case .Import(let module):
            interfaces.append(Declaration.Import(module: module))
            attributes.removeAll()
        case .Function(let function):
            interfaces.append(Declaration.Function(function: function))
            attributes.removeAll()
        }
    }
    
    return interfaces
}