//
//  Random.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Random {
    static func generate<T: RandomGenerable>() -> T {
        return T.generateRandom()
    }

    static func generate<T: RandomGenerable>() -> T? {
        if arc4random() % 6 == 0 {
            return T.generateRandom()
        }
        else {
            return nil
        }
    }

    static func generate<T: RandomGenerable>() -> [T] {
        return Array(0 ... 5 + arc4random() % 20).map { _ -> T in
            T.generateRandom()
        }
    }
}

protocol RandomGenerable {
    static func generateRandom() -> Self
}

extension String : RandomGenerable {
    static func generateRandom() -> String {
        var string = ""
        
        for _ in 0 ..< arc4random() % 50 {
            if arc4random() % 6 == 0 {
                string += " "
            }
            else {
                let z = "z".unicodeScalars.first!
                let a = "a".unicodeScalars.first!
                string.append(UnicodeScalar(a.value + arc4random() % (z.value - a.value)))
            }
        }
        
        return string
    }
}

extension Int : RandomGenerable {
    static func generateRandom() -> Int {
        return Int(arc4random() % 10000)
    }
}

extension UInt : RandomGenerable {
    static func generateRandom() -> UInt {
        return UInt(arc4random() % 10000)
    }
}

extension Int32 : RandomGenerable {
    static func generateRandom() -> Int32 {
        return Int32(arc4random() % 10000)
    }
}

extension UInt32 : RandomGenerable {
    static func generateRandom() -> UInt32 {
        return UInt32(arc4random() % 10000)
    }
}

extension Int64 : RandomGenerable{
    static func generateRandom() -> Int64 {
        return Int64(arc4random() % 10000)
    }
}

extension UInt64 : RandomGenerable {
    static func generateRandom() -> UInt64 {
        return UInt64(arc4random() % 10000)
    }
}

extension Float : RandomGenerable {
    static func generateRandom() -> Float {
        return Float(arc4random() % 10000)
    }
}

extension Double : RandomGenerable {
    static func generateRandom() -> Double {
        return Double(arc4random() % 10000)
    }
}

extension Bool : RandomGenerable {
    static func generateRandom() -> Bool {
        return arc4random() % 2 == 0
    }
}

class Random : CodeGeneratorBase, CodeGeneratorType {
    let implementation: String?
    
    init(implementation: String? = nil) {
        self.implementation = implementation
        super.init()
    }
    
    func generateInterfaces() -> [InterfaceMetadata] {
        return []
    }
    
    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle) {
        let implementationName: String
        if interfaceMetadata.interfaceType == .Protocol_ {
            if let explicitName = self.implementation {
                implementationName = explicitName
            }
            else {
                file.write("/* Interface implementation not specified, please use `Json(implementation: \"Value\")` for `\(interfaceMetadata.type)` */ ")
                return
            }
        }
        else {
            implementationName = interfaceMetadata.type.description
        }
        
        let write = {
            file.writeln("return \(implementationName)(\n            " + ",\n            ".join(interfaceMetadata.properties.map { "\($0.name): Random.generate()" }) + "\n        )")
        }
        
        if interfaceMetadata.interfaceType == .Protocol_ {
            file.writeln("// Random for \(interfaceMetadata.type)")
            file.writeln("")
            file.writeBlock("extension Random") {
                file.writeBlock("static func generate() -> \(interfaceMetadata.type)") {
                    write()
                }
            
                file.writeBlock("static func generate() -> \(interfaceMetadata.type)?") {
                    file.writeBlock("if arc4random() % 6 == 0") {
                        file.writeln("return generate()")
                    }
                    file.writeBlock("else") {
                        file.writeln("return nil")
                    }
                }

                file.writeBlock("static func generate() -> [\(interfaceMetadata.type)]") {
                    file.writeBlock("return Array(0 ... arc4random()).map") { file.writeln("_ -> \(interfaceMetadata.type) in")
                        file.writeln("generate()")
                    }
                }
            }
        }
        else {
            // if final, we can make sure it implements RandomGenerable
            if interfaceMetadata.modifiers.contains(Modifier.Final) {
                file.writeBlock("extension \(interfaceMetadata.type) : RandomGenerable") {
                    file.writeBlock("static func generateRandom() -> \(interfaceMetadata.type)") {
                        write()
                    }
                }
            }
            else {
                file.writeBlock("extension Random") {
                    file.writeBlock("static func generate() -> \(interfaceMetadata.type)") {
                        write()
                    }
                    
                    file.writeBlock("static func generate() -> \(interfaceMetadata.type)?") {
                        file.writeBlock("if arc4random() % 6 == 0") {
                            file.writeln("return generate() as \(interfaceMetadata.type)")
                        }
                        file.writeBlock("else") {
                            file.writeln("return nil")
                        }
                    }
                    
                    file.writeBlock("static func generate() -> [\(interfaceMetadata.type)]") {
                        file.writeBlock("return Array(0 ... arc4random() % 20).map") { file.writeln("_ -> \(interfaceMetadata.type) in")
                            file.writeln("generate() as \(interfaceMetadata.type)")
                        }
                    }
                }
            }
        }
    }
}