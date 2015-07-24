//
//  Parser.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/16/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


// https://en.wikipedia.org/wiki/Formal_grammar

struct ParsePosition : Comparable, CustomStringConvertible {
    let characterIndex: String.UnicodeScalarView.Index
    let characterView: Box<String.UnicodeScalarView>
    let string: Box<String>
    let farthestPosition: MutableBox<ParsePosition!>
    
    var character: UnicodeScalar? {
        get {
            return characterIndex == characterView.value.endIndex
                ? nil
                : characterView.value[characterIndex]
        }
    }
    
    init(atStart: String, farthestPosition: MutableBox<ParsePosition!>) {
        let characterView = atStart.unicodeScalars
        self.characterIndex = characterView.startIndex
        self.characterView = Box(characterView)
        self.string = Box(atStart)
        self.farthestPosition = farthestPosition
        self.farthestPosition.value = self
    }
    
    private init(string: Box<String>, characterView: Box<String.UnicodeScalarView>, characterIndex: String.UnicodeScalarView.Index, farthestPosition: MutableBox<ParsePosition!>) {
        self.characterView = characterView
        self.characterIndex = characterIndex
        self.string = string
        self.farthestPosition = farthestPosition
        
        /*
        let distance = self.characterIndex - self.characterView.value.startIndex
        
        if distance >= 597 {
            print("here")
        }*/
    }
    
    var next: ParsePosition {
        let parsePosition = ParsePosition(string: self.string, characterView: self.characterView, characterIndex: self.characterIndex.successor(), farthestPosition: self.farthestPosition)
        
        if self.farthestPosition.value.characterIndex < parsePosition.characterIndex {
            self.farthestPosition.value = parsePosition
        }
        
        return parsePosition
    }
    
    func stringValueBetween(end: ParsePosition) -> String {
        assert(end.characterIndex >= self.characterIndex)
        
        var nextPosition = self.characterIndex
        
        var stringValue = ""
        
        while nextPosition < end.characterIndex {
            stringValue.append(self.characterView.value[nextPosition])
            nextPosition = nextPosition.successor()
        }
        
        return stringValue
    }
    
    var description: String {
        let distance = self.characterIndex - self.characterView.value.startIndex
        let index = self.characterIndex.samePositionIn(self.string.value)
        
        let lineCounter = self.string.value.substringToIndex(index ?? self.string.value.startIndex)
        
        let numberOfLines = lineCounter.componentsSeparatedByString("\n").count + 1
        
        let remaining = self.string.value.substringFromIndex(index ?? self.string.value.startIndex)
        let take = 80
        let prefix = remaining.substringToIndex(advance(remaining.startIndex, take, remaining.endIndex))
        let end = remaining.utf16.count > take ? "..." : ""
        
        return "\(distance), line \(numberOfLines) -> `\(prefix)`\(end)"
    }
}

func ==(lhs: ParsePosition, rhs: ParsePosition) -> Bool {
    return lhs.characterIndex == rhs.characterIndex
}

func <(lhs: ParsePosition, rhs: ParsePosition) -> Bool {
    return lhs.characterIndex < rhs.characterIndex
}
func <=(lhs: ParsePosition, rhs: ParsePosition) -> Bool {
    return lhs.characterIndex <= rhs.characterIndex
}
func >=(lhs: ParsePosition, rhs: ParsePosition) -> Bool {
    return lhs.characterIndex >= rhs.characterIndex
}
func >(lhs: ParsePosition, rhs: ParsePosition) -> Bool {
    return lhs.characterIndex > rhs.characterIndex
}
func -(lhs: String.UnicodeScalarView.Index, rhs: String.UnicodeScalarView.Index) -> Int {
    var distance = 0
    var index = lhs
    while index < rhs {
        index = index.successor()
        distance--
    }
    while index > rhs {
        index = index.predecessor()
        distance++
    }
    return distance
}

protocol Parser {
    typealias Result
    
    // first part is sucessfully parsed
    func parseAt(position: ParsePosition) -> [(Result, ParsePosition)]
}

class ParserOf<R>: Parser {
    typealias Result = R
    typealias ParseResult = [(Result, ParsePosition)]
    typealias ParseFunc = (ParsePosition) -> ParseResult
    
    let parse: ParseFunc
    
    init<P: Parser where P.Result == Result>(parser: P) {
        self.parse = { p in
            parser.parseAt(p)
        }
    }
    
    init(parse: (ParsePosition) -> ParseResult) {
        self.parse = parse
    }
    
    func parseAt(position: ParsePosition) -> ParseResult {
        return parse(position)
    }
}

class RecursiveParser<R>: Parser {
    typealias Result = R
    typealias ParserGenerator = (RecursiveParser<R>) -> ParserOf<R>
    
    let parserGenerator: ParserGenerator
    var memoizedParser: RecursiveParser<R>?
    
    init(parserGenerator: ParserGenerator) {
        self.parserGenerator = parserGenerator
    }
    
    func parseAt(p: ParsePosition) -> [(Result, ParsePosition)] {
        if memoizedParser == nil {
            self.memoizedParser = RecursiveParser(parserGenerator: self.parserGenerator)
        }
        return self.parserGenerator(memoizedParser!).parseAt(p)
    }
}

class DebugParserOf<R>: Parser {
    
    let parser: ParserOf<R>
    
    init<P: Parser where P.Result == R>(_ parser: P, _ name: String) {
        self.parser = ParserOf { p in
            let result = parser.parseAt(p)
            print("parsed \(name) at \(p) with `\(result)`")
            
            return result
        }
    }
    
    func parseAt(p: ParsePosition) -> [(R, ParsePosition)] {
        return self.parser.parseAt(p)
    }
}

class ParserChain<R>: Parser {
    typealias Result = R
    typealias ParseResult = [(Result, ParsePosition)]

    var parseRight: ParserOf<R>!
    
    func parseAt(p: ParsePosition) -> ParseResult {
        return []
    }
}

class NonterminalSymbol<P: Parser, R> : ParserChain<R> {
    typealias Result = R
    
    let name: Name<P>
    
    init(name: Name<P>) {
        self.name = name
    }
    
    override func parseAt(position: ParsePosition) -> ParseResult {
        let result = self.name.parser.parseAt(position)
        return result.flatMap { nextPosition -> ParseResult in
            self.name._value = nextPosition.0
            return self.parseRight!.parseAt(nextPosition.1)
        }
        
    }
}


func constant<T>(constant: String, value: T) -> ParserOf<T> {
    return ParserOf { p in
        var position = p
        for c in constant.unicodeScalars {
            if position.character != c {
                return []
            }
            position = position.next
        }
        
        return [(value, position)]
    }
}

func constant(c: String) -> ParserOf<Void> {
    return constant(c, value: ())
}

func not(constant: UnicodeScalar) -> ParserOf<Void> {
    return ParserOf { p in
        if p.character == constant {
            return []
        }
        else {
            return [((), p.next)]
        }
    }
}

func combine<R>(parsers: ParserOf<R> ...) -> ParserOf<R> {
    return ParserOf { p in
        return parsers.flatMap { parser in
            return parser.parse(p)
        }
    }
}

func first<R>(parsers: ParserOf<R> ...) -> ParserOf<R> {
    return ParserOf { p in
        for parser in parsers {
            let results = parser.parseAt(p)
            if results.count > 0 {
                return results
            }
        }
        return []
    }
}

extension Parser {
    func map<E>(transform: (Result, ParsePosition, ParsePosition) -> E) -> ParserOf<E> {
        return ParserOf { p in
            let all = self.parseAt(p)
                
            return all.map { (r, end) in
                return (transform(r, p, end), end)
            }
        }
    }
    
    var onePlus: ParserOf<[Result]> {
        let start = Name(self)
        let others = Name(self.zeroPlus)
        return begin(start)
            .then(others)
            .parse {
                var result = others.value
                result.insert(start.value, atIndex: 0)
                
                return result
            }
    }
    
    var optional: ParserOf<Result?> {
        return ParserOf { p in
            let result = self.parseAt(p)
            if result.count > 0 {
                return result.map { ($0.0, $0.1) }
            }
            
            return [(nil, p)]
        }
    }
    
    var parsedSubstring: ParserOf<String> {
        return self.map { (_, p, end) in
            return p.stringValueBetween(end)
        }
    }
    
    var zeroPlus: ParserOf<[Result]> {
        return zeroPlusSeparatedBy(constant(""))
    }
    
    func zeroPlusSeparatedBy(separator: ParserOf<Void>) -> ParserOf<[Result]> {
        return ParserOf { p in
            var results = [([Result], ParsePosition)]()
            
            var last = [(MutableBox<[Result]>, ParsePosition)]()
            var next = [(MutableBox<[Result]>, ParsePosition)]()
            
            next.append(MutableBox<[Result]>([]), p)
            
            var farthest = p
            
            let firstParser = ParserOf(parser: self)
            
            let meAgain = Name(self)
            let secondParser: ParserOf<Result> = begin(separator)
                    .then(meAgain)
                    .parse {
                        return meAgain.value
                    }
            
            var first = true
            
            while !next.isEmpty {
                last = next
                next.removeAll(keepCapacity: true)
                
                for p in last {
                    let subResults = (first ? firstParser : secondParser).parseAt(p.1)
                    
                    if subResults.count == 0 {
                        let result = (p.0.value, p.1)
                        results.append(result)
                    }
                    // optimized most common case
                    // this is not the fastest parser out there, but doesn't mean it should be O(n^2)
                    else if subResults.count == 1 {
                        let first = subResults[0]
                        var nextSearch = p
                        nextSearch.0.value.append(first.0)
                        nextSearch.1 = first.1
                        
                        if first.1 > farthest {
                            farthest = first.1
                        }
                        
                        // compiler
                        next.append(nextSearch.0 as MutableBox<[Result]>, nextSearch.1 as ParsePosition)
                    }
                    // it will probably blow up exponentially anyway, shouldn't care about performance
                    else {
                        for r in subResults {
                            let nextResults = MutableBox(p.0.value)
                            nextResults.value.append(r.0 as Result)
                            next.append(nextResults, r.1)
                        }
                    }
                }
                
                first = false
            }
            
            return results
        }
    }
}