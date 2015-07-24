//
//  Production.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func begin<P: Parser, R>(name: Name<P>) -> Production<R> {
    return Production(leftSymbol: NonterminalSymbol(name: name))
}

func begin<P: Parser, R>(parser: P) -> Production<R> {
    return Production(leftSymbol: NonterminalSymbol(name: Name(parser)))
}

class Production<R> {
    var namedSymbols: [ParserChain<R>]
    
    init(leftSymbol: ParserChain<R>) {
        self.namedSymbols = []
        self.namedSymbols.append(leftSymbol)
    }
    
    func parse(parse: () -> R) -> ParserOf<R> {
        for (i, p) in namedSymbols[1..<namedSymbols.count].enumerate() {
            namedSymbols[i].parseRight = ParserOf(parser: p)
        }
        
        namedSymbols.last!.parseRight = ParserOf { p in
            return [(parse(), p)]
        }
        
        return ParserOf { p in
            return self.namedSymbols[0].parseAt(p)
        }
    }
    
    func then<P: Parser>(name: Name<P>) -> Production<R> {
        self.namedSymbols.append(NonterminalSymbol(name: name))
        return self
    }
    
    func then<P: Parser>(parser: P) -> Production<R> {
        self.namedSymbols.append(NonterminalSymbol(name: Name(parser)))
        return self
    }
}

