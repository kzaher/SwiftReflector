//
//  Example.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// *** Those attributes are just normal Swfit code ***
//
//{ NSDate.isAprilFirst ? Silly() : Nothing() }
//{ Value() }
//{ Class(implementation: "DuckSecretClass") }
//{ Json(implementation: "Duck") }
//{ Random(implementation: "Duck") }
protocol DuckType {
    
    var name: String { get }
    var rank: String { get set }
    
    //{ JsonAttribute(path: "dateOfBirth", deserialize: "relativeDate") }
    var age: Int { get }
    
    var spouse: DuckType? { get }
    
    var plansForFuture: [Plan] { get }
 
    // You can also use normal comments
    var personality: PersonalityType { get }
}

//{ Value(implementation: "Personality") }
//{ Json(implementation: "Personality")  }
//{ IsHashable() }
//{ Random(implementation: "Personality") }
protocol PersonalityType {
    var isFun: Bool { get }
    var isSafeFlyer: Bool { get }
    
    //{ JsonAttribute(path: "duckCaptain") }
    var isAlphaDuck: Bool { get }
}

// it works on structs also
//
//{ Json() }
//{ Random() }
struct Plan {
    var isItGood: Bool?
    var goals: [String]
    var chanceOfSuccess: Float
}


//{ Random() }
class AloneClass {
    let a: Int
    
    init(a: Int) {
        self.a = a
    }
    
    // We don't parse function internals, just make sure they have matching
    // number of `{`/`}`, so you can go wild here :)
    func someFunction() {
        print(a)
    }
}