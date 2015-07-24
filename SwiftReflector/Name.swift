//
//  Name.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


class Name<P: Parser> {
    typealias T = P.Result
    
    var _value: T!
    
    var value: T {
        get {
            return _value
        }
    }
    
    let parser: P
    
    init(_ parser: P) {
        self.parser = parser
    }
}