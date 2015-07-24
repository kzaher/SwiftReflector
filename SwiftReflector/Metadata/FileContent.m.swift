//
//  FileContent.m.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

final class SourceFile {
    var path: String
    var declarations: [Declaration]
    
    init(path: String, declarations: [Declaration]) {
        self.path = path
        self.declarations = declarations
    }
}

extension SourceFile : CustomStringConvertible {
    var description: String {
        return "FileContent(path: \(path)) {\n\(declarations)\n}"
    }
}