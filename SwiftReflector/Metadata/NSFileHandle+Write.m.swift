//
//  NSFileHandle+Write.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

var indentContext: UInt8 = 0

typealias WriteAction = () -> ()

extension NSFileHandle {
    func write(string: String) {
        self.writeData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    func writeln(string: String) {
        let indentString = "".stringByPaddingToLength(indent() * 4, withString: " ", startingAtIndex: 0)
        self.write(indentString + string + "\n")
    }
    
    func indent() -> Int {
        return objc_getAssociatedObject(self, &indentContext) as? Int ?? 0
    }
    
    func setIndent(indent: Int) {
        objc_setAssociatedObject(self, &indentContext, indent, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
    
    func writeBlock(string: String, write: WriteAction) {
        let indentValue = indent()
        
        writeln(string + " { ")
        setIndent(indentValue + 1)
        write()
        setIndent(indentValue)
        writeln("}")
    }
}