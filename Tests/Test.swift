//
//  Test.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/18/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest

class TestParser : XCTestCase {
    func testParseModifiers() {
        let header = "public final"
        
        let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
        let startPosition = ParsePosition(atStart: header, farthestPosition: farthestPosition)
        let results = modifiersParser.parseAt(startPosition)
        XCTAssertEqual(results[0].0, [Modifier.Public, Modifier.Final])
    }
    
    func testParseClass() {
        let header = " public final class A { }"
        
        let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
        let startPosition = ParsePosition(atStart: header, farthestPosition: farthestPosition)
        let results = interfaceParser.parseAt(startPosition)
        
        XCTAssertEqual(results.first!.0, InterfaceMetadata(
            interfaceType: InterfaceType.Class,
            type: Type.Normal("A", []),
            inherits: [],
            modifiers: [Modifier.Public, Modifier.Final],
            properties: [],
            functions: [],
            enumCases: [],
            typealiases: [],
            serializedAttributes: []
            )
        )
    }
    
    func testParseClass2() {
        let header = " public final class A<b, C> { }"
        
        let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
        let startPosition = ParsePosition(atStart: header, farthestPosition: farthestPosition)
        
        let results = interfaceParser.parseAt(startPosition)
        
        XCTAssertEqual(results.first!.0, InterfaceMetadata(
            interfaceType: InterfaceType.Class,
            type: Type.Normal("A", [Type.Normal("b", []), Type.Normal("C", [])]),
            inherits: [],
            modifiers: [Modifier.Public, Modifier.Final],
            properties: [],
            functions: [],
            enumCases: [],
            typealiases: [],
            serializedAttributes: []
            )
        )
    }
    
    func parseExperiment<P: Parser>(value: String, _ parser: P) throws -> P.Result {
        let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
        let startPosition = ParsePosition(atStart: value, farthestPosition: farthestPosition)
        
        let results = parser.parseAt(startPosition)
        
        
        if results.count == 0 {
            print(farthestPosition)
            throw NSError(
                domain: SwiftReflectorDomain,
                code: SwiftReflectorError.ParseError.rawValue,
                userInfo: [SwiftReflectorErrorFarthestKey : Box(farthestPosition.value)]
            )
        }
        else if results.count > 1 {
            print(farthestPosition)
            print(results)
            throw NSError(
                domain: SwiftReflectorDomain,
                code: SwiftReflectorError.Ambiguous.rawValue,
                userInfo: [SwiftReflectorErrorParsedDeclarationsKey : Box(results)]
            )
        }
        
        let (r, position) = results[0]
        
        if position.characterIndex != position.characterView.value.endIndex {
            print(farthestPosition)
            throw NSError(
                domain: SwiftReflectorDomain,
                code: SwiftReflectorError.ParseError.rawValue,
                userInfo: [SwiftReflectorErrorFarthestKey : Box(farthestPosition.value)]
            )
        }
     
        return r
    }
    
    func testParseClass3() {
        let header = " public final class A<b, C> : Ante<A, _b> , ceta { }"
        
        let farthestPosition: MutableBox<ParsePosition!> = MutableBox(nil)
        let startPosition = ParsePosition(atStart: header, farthestPosition: farthestPosition)
        
        let results = interfaceParser.parseAt(startPosition)
        
        let ante = Type.Normal("Ante", [Type.Normal("A", []), Type.Normal("_b", [])])
        let materija = Type.Normal("ceta", [])
        
        let expected = InterfaceMetadata(
            interfaceType: InterfaceType.Class,
            type: Type.Normal("A", [Type.Normal("b", []), Type.Normal("C", [])]),
            inherits: [ante, materija],
            modifiers: [Modifier.Public, Modifier.Final],
            properties: [],
            functions: [],
            enumCases: [],
            typealiases: [],
            serializedAttributes: []
        )
        
        XCTAssertEqual(results.first!.0, expected)
    }
    
    func testParseArray() {
        let res = try! parseExperiment(" [ Int? ] ?", typeParser)
        XCTAssertEqual(res, Type.Normal("Optional", [Type.Normal("Array", [Type.Normal("Optional", [Type.Normal("Int", [])])])]))
    }

    func testParseFile() {
        let header =
        " // header\n" +
        "\n" +
        " typealias a = what\n" +
        " import Module1 \n" +
        " import Module2\n" +
        "\n" +
        "           //{ classAttribute } not this\n" +
        "\n" +
        " public final class A<b, C> : Ante<A, _b> , ceta { \n" +
        "\n" +
        " //{ attribute1 } this is comment\n" +
        " dynamic public override let a: T<t1, t2> { get { what is there { } } set }\n" +
        "  \n" +
        "  dynamic private func ahoj(h: t< T1, T2 >, h2: B) -> T3 -> T4\n" +
        "  \n" +
        "  func ahoj2(h: t< T2, T2 >) {  This is some content { we don't care } }\n" +
        "  //{ 1 }\n" +
        "  var genericArray: [Int<O1>?]?{ get }\n" +
        "  var fn: (([Int<O1>?]?) -> [String:Int?]) { get set }\n" +
        "  public var tupac: ((String?, Int))\n" +
        "  public init(a: Int) { super.init(a) }\n" +
        "  deinit { println(x) }\n" +
        "  case TestCase(a: Int, b: String)\n" +
        "  case TestCase2\n" +
        "\n" +
        "}\n"
        
        do {
            let ante = Type.Normal("Ante", [Type.Normal("A", []), Type.Normal("_b", [])])
            let materija = Type.Normal("ceta", [])
            
            let complexType = Type.Normal("Optional", [Type.Normal("Array", [Type.Normal("Optional", [Type.Normal("Int", [Type.Normal("O1", [])])])])])
            
            let returnType = Type.Normal("Dictionary", [Type.Normal("String", []), Type.Normal("Optional", [Type.Normal("Int", [])])])
            
            let access = AccessType.GetterAndSetter
            let properties: [PropertyMetadata] = [
                PropertyMetadata(name: "a",
                    type: Type.Normal("T", [Type.Normal("t1", []), Type.Normal("t2", [])]),
                    modifiers: [Modifier.Dynamic, Modifier.Public, Modifier.Override],
                    accessType: access,
                    serializedAttributes: [
                        "attribute1"
                    ]),
                PropertyMetadata(name: "genericArray",
                    type: complexType,
                    modifiers: [],
                    accessType: AccessType.Getter,
                    serializedAttributes: [
                        "1"
                    ]),
                PropertyMetadata(name: "fn",
                    type: Type.Function(complexType, returnType),
                    modifiers: [],
                    accessType: AccessType.GetterAndSetter,
                    serializedAttributes: [
                    ]),
                PropertyMetadata(name: "tupac",
                    type: Type.Tuple([Type.Normal("Optional", [Type.Normal("String", [])]), Type.Normal("Int", [])]),
                    modifiers: [Modifier.Public],
                    accessType: AccessType.GetterAndSetter,
                    serializedAttributes: [
                    ])
            ]
            
            let functions: [FunctionMetadata] = [
                FunctionMetadata(name: "ahoj",
                    arguments: [
                        ArgumentMetadata(name: "h", type: Type.Normal("t", [Type.Normal("T1", []), Type.Normal("T2", [])])),
                        ArgumentMetadata(name: "h2", type: Type.Normal("B", [])),
                    ],
                    returnType:
                        Type.Function(
                            Type.Normal("T3", []),
                            Type.Normal("T4", [])
                        ),
                    modifiers: [Modifier.Dynamic, Modifier.Private]
                ),
                FunctionMetadata(name: "ahoj2",
                    arguments: [
                        ArgumentMetadata(name: "h", type: Type.Normal("t", [Type.Normal("T2", []), Type.Normal("T2", [])]))
                    ],
                    returnType: Type.void,
                    modifiers: []
                ),
                FunctionMetadata(name: "init",
                    arguments: [ArgumentMetadata(name: "a", type: Type.Normal("Int", []))],
                    returnType: Type.void,
                    modifiers: [Modifier.Public]
                ),
                FunctionMetadata(name: "deinit",
                    arguments: [],
                    returnType: Type.void,
                    modifiers: []
                )
            ]
            
            let enumCases = [
                EnumCaseMetadata(
                    name: "TestCase",
                    arguments: [
                        ArgumentMetadata(name: "a", type: Type.Normal("Int", [])),
                        ArgumentMetadata(name: "b", type: Type.Normal("String", [])),
                    ],
                    modifiers: []),
                EnumCaseMetadata(
                    name: "TestCase2",
                    arguments: [],
                    modifiers: []
                )
            ]
            
            let expected = InterfaceMetadata(
                interfaceType: InterfaceType.Class,
                type: Type.Normal("A", [Type.Normal("b", []), Type.Normal("C", [])]),
                inherits: [ante, materija],
                modifiers: [Modifier.Public, Modifier.Final],
                properties: properties,
                functions: functions,
                enumCases: enumCases,
                typealiases: [],
                serializedAttributes: [
                    "classAttribute"
                ]
            )

            let declarations = try parseFile(header)
            
            XCTAssertEqual(declarations, [
                Declaration.Import(module: "Module1"),
                Declaration.Import(module: "Module2"),
                Declaration.Interface(interface: expected)
            ])
            
            let parsedFile = SourceFile(path: "home", declarations: declarations)
            
            let serialized: AnyObject = [parsedFile].toJson()
            let deserializedContentsFromJson = try Json.deserialize(serialized) as [SourceFile]
            
            XCTAssertEqual(deserializedContentsFromJson, [parsedFile])
        }
        catch let error {
            let e = error as NSError
            let latest = (e.userInfo["SwiftReflectorFarthest"] as? Box<ParsePosition!>)?.value?.description ?? ""
            print(latest)
            print(error)
            XCTFail()
        }
    }
    
    func testCoreDataSerialization() {
        let data = "/Users/kzaher/Projects/SwiftReflector/Resources/CoreDataTestModel.xcdatamodeld/CoreDataTestModel.xcdatamodel"
        
        let model = data.stringByAppendingPathComponent("CoreDataTestModel.xcdatamodel/contents")
        
        //let modelXml = try! NSXMLDocument(contentsOfURL: NSURL(string: model)!, options: 0)
        
        
    }
}