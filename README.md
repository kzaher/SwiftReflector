SwiftReflector
==============

***Requires Swift 2.0 Xcode 7 beta 4***

... is a `Swift` program that extracts attributes written in form of standard `Swift` expressions from `Swift` source files and generates `Swift` source code using metaprogramming transformations written in `Swift`.

Features:

* Attributes can be any Swift expressions
* You can easily plug in your Swift logic that generates metadata or code
* Configure generated file locations
* Use autocomplete while writing metaprograms

Content

1. [Why](#Why)
1. [How does it work?](#How does it work)
1. [Typical usage](#Typical usage)
1. [Installation](#Installation)

# Why

Writing code is tedious task, but there is a lot of cases where huge amount of code can be generated by a pure function depending on some source code subset.

* JSON parsing
* generating random data
* data layer (core data or endpoint layer)
* serialization
* implement protocol as struct or class

You can write general logic first and if there are any exceptions to that general case, you can mark them with attributes and modify generated code to fit perfectly with general case.

During code generation process you can access full metadata about reflected code:

* Attributes
* Type - Identifier, Generics, Optionals, Array, Dictionaries, Tuples, Functions, ...
* Identifier
* Modifiers - Public, Private, Protected, Static ...
* Inheritance chain
* Function arguments/return value
* Does it have Getters/Setters

```swift

//{ JsonAttribute(path: "dateOfBirth", transform: relativeDate) }
var age: Int { get }

```

The reason why this project is called SwiftReflector is because the purpose of reflection is to modify behavior of the program depending on metadata assigned to some structures in source code.

Different languages have different ways of handling this problem. Basically it comes down to Runtime vs Compile time. I choose compile time where ever I can :)

# How does it work?

It has a simple top down parser that extracts all of the metadata from source code files. For now it parses a subset of Swift, but the end goal is to hook it up to LLVM frontend once Swift becomes open source. It can be improved easily in the mean time.

The parser looks for comments in this format `//{ equal number of opening and closing parenthesis }` (looks like lambda), and assigns those as attributes to following declarations. If the expression is not a valid Swift expression, metaprogram compilation will fail and you will for sure know about it :)

To mark files as files that will be reflected insert ".r." in filename.

This is needed for performance reasons and because the parser currently parses only a subset of `Swift`. ***This only relates to `.r.` files, in metaprograms and attributes you can use full swift code with autocomplete.***

After it parses those files and extracts attributes as strings, it generates code to evaluate those attributes together with content of metadata files marked with `.m.`.

If attribute implements `MetadataGeneratorType` protocol, it has the ability to generate custom interfaces.

```swift
protocol MetadataGeneratorType {

    func generateInterfaces(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> [InterfaceMetadata]

}
```

If attribute implements `CodeGeneratorType` it can generate source code files.

```swift
protocol CodeGeneratorType {

    func pathForGeneratedSourceCode(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType) -> String

    func write(interfaceMetadata: InterfaceMetadata, metadata: ModuleMetadataType, file: NSFileHandle)

}
```

# Typical usage

Choose files that you want to reflect by inserting `.r.`. E.g.

```
Example.r.swift
```

Take it easy with content of those `.r.` files for now before we can move to LLVM frontend. Defining simple protocols, structs and classes should be fine.

Copy swift reflector and `.m.` files from `Metadata`, `Generators` folder to your project.

You can just include those core `.m.` files to one of your project targets and write your own custom `.m.` files in Xcode. Just be careful to reference only classes from existing `.m.` files or some framework that system has access to. Those files will be compiled when evaluating attribute values, so they need to be compilable as a unit :)

```
cd [path to my project]
./[path to reflector binary]/SwiftReflector
```

This will recursively search for `.r.` and `.m.` files and do the funky thing of generating Swift source files.

Here is an example `.r.` file

```swift
import Foundation

// *** Those attributes are just normal Swift code ***
//
//{ NSDate.isAprilFirst ? Silly() : Nothing() }
//{ Value() }
//{ Class(implementation: "DuckSecretClass") }
//{ Json(implementation: "Duck") }
//{ Random(implementation: "Duck") }
protocol DuckType {

    var name: String { get }
    var rank: String { get set }

    //{ JsonAttribute(path: "dateOfBirth", transform: relativeDate) }
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
```

Now you can just write

```swift
print(Random.generate() as DuckType)
```

or

```swift
print(Json.deserialize(json) as DuckType)
```


# Installation

## Manual


```
git clone git@github.com:kzaher/SwiftReflector.git
```

***Requires Swift 2.0 Xcode 7 beta 4***

Copy swift reflector and `.m.` files from `Metadata`, `Generators` folder to your project, and SwiftReflector product to somewhere convenient.

Compile the `SwiftReflector`

## Release zip

Download latest zip file from [releases](https://github.com/kzaher/SwiftReflector/releases)

Copy swift reflector and `.m.` files from `Metadata`, `Generators` folder to your project, and SwiftReflector product to somewhere convenient.
