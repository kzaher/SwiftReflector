// Autogenerated `SwiftReflector` @ 2015-07-24 09:16:39 +0000

import Foundation

// Plan

extension Random { 
    static func generate() -> Plan { 
        return Plan(
            isItGood: Random.generate(),
            goals: Random.generate(),
            chanceOfSuccess: Random.generate()
        )
    }
    static func generate() -> Plan? { 
        if arc4random() % 6 == 0 { 
            return generate() as Plan
        }
        else { 
            return nil
        }
    }
    static func generate() -> [Plan] { 
        return Array(0 ... arc4random() % 20).map { 
            _ -> Plan in
            generate() as Plan
        }
    }
}

// DuckType

// Random for DuckType

extension Random { 
    static func generate() -> DuckType { 
        return Duck(
            name: Random.generate(),
            rank: Random.generate(),
            age: Random.generate(),
            spouse: Random.generate(),
            plansForFuture: Random.generate(),
            personality: Random.generate()
        )
    }
    static func generate() -> DuckType? { 
        if arc4random() % 6 == 0 { 
            return generate()
        }
        else { 
            return nil
        }
    }
    static func generate() -> [DuckType] { 
        return Array(0 ... arc4random()).map { 
            _ -> DuckType in
            generate()
        }
    }
}

// PersonalityType

// Random for PersonalityType

extension Random { 
    static func generate() -> PersonalityType { 
        return Personality(
            isFun: Random.generate(),
            isSafeFlyer: Random.generate(),
            isAlphaDuck: Random.generate()
        )
    }
    static func generate() -> PersonalityType? { 
        if arc4random() % 6 == 0 { 
            return generate()
        }
        else { 
            return nil
        }
    }
    static func generate() -> [PersonalityType] { 
        return Array(0 ... arc4random()).map { 
            _ -> PersonalityType in
            generate()
        }
    }
}

// AloneClass

extension Random { 
    static func generate() -> AloneClass { 
        return AloneClass(
            a: Random.generate()
        )
    }
    static func generate() -> AloneClass? { 
        if arc4random() % 6 == 0 { 
            return generate() as AloneClass
        }
        else { 
            return nil
        }
    }
    static func generate() -> [AloneClass] { 
        return Array(0 ... arc4random() % 20).map { 
            _ -> AloneClass in
            generate() as AloneClass
        }
    }
}


