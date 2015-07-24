// Autogenerated `SwiftReflector` @ 2015-07-24 09:44:25 +0000

import Foundation

// Personality

struct Personality : PersonalityType { 
    var isFun: Bool
    var isSafeFlyer: Bool
    var isAlphaDuck: Bool
    
    init(isFun: Bool, isSafeFlyer: Bool, isAlphaDuck: Bool) { 
        self.isFun = isFun
        self.isSafeFlyer = isSafeFlyer
        self.isAlphaDuck = isAlphaDuck
    }
}

extension Personality : CustomStringConvertible { 
    var description: String { 
        return "Personality(\n"
            +  "    isFun: \(prettyDescription(isFun)),\n"
            +  "    isSafeFlyer: \(prettyDescription(isSafeFlyer)),\n"
            +  "    isAlphaDuck: \(prettyDescription(isAlphaDuck))\n"
            +  ")"
    }
}

// Duck

struct Duck : DuckType { 
    var name: String
    var rank: String
    var age: Int
    var spouse: Optional<DuckType>
    var plansForFuture: Array<Plan>
    var personality: PersonalityType
    
    init(name: String, rank: String, age: Int, spouse: Optional<DuckType>, plansForFuture: Array<Plan>, personality: PersonalityType) { 
        self.name = name
        self.rank = rank
        self.age = age
        self.spouse = spouse
        self.plansForFuture = plansForFuture
        self.personality = personality
    }
}

extension Duck : CustomStringConvertible { 
    var description: String { 
        return "Duck(\n"
            +  "    name: \(prettyDescription(name)),\n"
            +  "    rank: \(prettyDescription(rank)),\n"
            +  "    age: \(prettyDescription(age)),\n"
            +  "    spouse: \(prettyDescription(spouse)),\n"
            +  "    plansForFuture: \(prettyDescription(plansForFuture)),\n"
            +  "    personality: \(prettyDescription(personality))\n"
            +  ")"
    }
}

// DuckSecretClass

class DuckSecretClass : DuckType { 
    var name: String
    var rank: String
    var age: Int
    var spouse: Optional<DuckType>
    var plansForFuture: Array<Plan>
    var personality: PersonalityType
    
    init(name: String, rank: String, age: Int, spouse: Optional<DuckType>, plansForFuture: Array<Plan>, personality: PersonalityType) { 
        self.name = name
        self.rank = rank
        self.age = age
        self.spouse = spouse
        self.plansForFuture = plansForFuture
        self.personality = personality
    }
}

extension DuckSecretClass : CustomStringConvertible { 
    var description: String { 
        return "DuckSecretClass(\n"
            +  "    name: \(prettyDescription(name)),\n"
            +  "    rank: \(prettyDescription(rank)),\n"
            +  "    age: \(prettyDescription(age)),\n"
            +  "    spouse: \(prettyDescription(spouse)),\n"
            +  "    plansForFuture: \(prettyDescription(plansForFuture)),\n"
            +  "    personality: \(prettyDescription(personality))\n"
            +  ")"
    }
}


