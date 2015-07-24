//
//  main.swift
//  SwiftReflector
//
//  Created by Krunoslav Zaher on 7/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let tempDir = NSTemporaryDirectory()

func parseFilesFromDirectory(directory: NSURL) throws -> ([SourceFile], [String]) {
    var parsedFiles = [SourceFile]()
    var metadataFiles = [String]()
    
    for path in fileManager.subpathsAtPath(directory.absoluteString)! {
        if path.hasPrefix(".") {
            continue
        }

        if path == "build" || path.rangeOfString("/build/") != nil || path.hasPrefix("build/") {
            continue
        }
        
        let fileURL = directory.URLByAppendingPathComponent(path)
        
        if path.rangeOfString(".m.") != nil {
            metadataFiles.append(fileURL.absoluteString)
        }
        
        if path.rangeOfString(".r.") == nil {
            continue
        }
        
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExistsAtPath(fileURL.absoluteString, isDirectory: &isDirectory) {
            if isDirectory {
                continue
            }
        }
        
        let content = try NSString(contentsOfFile: fileURL.absoluteString, encoding: NSUTF8StringEncoding)
        
        do {
            let declarations = try parseFile(content as String)
            
            parsedFiles.append(SourceFile(path: fileURL.absoluteString, declarations: declarations))
        }
        catch let e {
            let error = e as NSError
            
            if error.domain != SwiftReflectorDomain {
                throw error
            }
            
            switch SwiftReflectorError(rawValue: error.code)! {
            case .ParseError:
                let position = error.userInfo[SwiftReflectorErrorFarthestKey] as! Box<ParsePosition!>
                print("There was a problem parsing `\(fileURL.absoluteString)`. Farthest parsable position:\n\(position)")
            case .Ambiguous:
                let ambiguous = error.userInfo[SwiftReflectorErrorParsedDeclarationsKey] as! Box<[([ParsedDeclaration], ParsePosition)]>
                let ast = "\n---- or ----\n".join(ambiguous.value.map { "\($0.0)" })
                print("There was a problem parsing `\(fileURL.absoluteString)`. Ambiguous AST:\n\(ast)")
            }
            
            throw error
        }
    }
    
    return (parsedFiles, metadataFiles)
}

func parseFiles(root: String) throws -> ([SourceFile], [String]) {
    return try parseFilesFromDirectory(NSURL(string: root)!)
}

func serializeToJson(parsedFiles: [SourceFile]) throws -> NSData {
    let result = parsedFiles.map {
        $0.toJson()
    }
    return try NSJSONSerialization.dataWithJSONObject(result, options: NSJSONWritingOptions(rawValue: 0))
}

func runProgram(program: String, arguments: [String]) -> String {
    let task = NSTask()
    task.launchPath = program
    task.arguments = arguments
    
    let serializedArguments = " ".join(arguments.map { "'" + $0 + "'" })
    print("current directory: \(fileManager.currentDirectoryPath)")
    print("\(program) \(serializedArguments)")
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.currentDirectoryPath = fileManager.currentDirectoryPath
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    
    print(output)
    
    if task.terminationStatus != 0 {
        exit(task.terminationStatus)
    }
    
    
    return output
}

func runMetadataProgramWithMetadataPath(metadataPath: String, attributesFilePath: String, metadataSourceCodePaths: [String]) {
    let metadataBin = tempDir.stringByAppendingPathComponent("metadata.bin")
    
    let arguments = ["-num-threads", "\(NSProcessInfo.processInfo().processorCount)", "-Onone", "-g"] + metadataSourceCodePaths + [attributesFilePath, "-o", metadataBin]
    
    runProgram("/usr/bin/swiftc", arguments: arguments)
    //let metadataCString = metadataBin.cStringUsingEncoding(NSUTF8StringEncoding)!
    //execve(metadataCString, nil, nil)
    runProgram(metadataBin, arguments: [metadataPath, attributesFilePath])
}

func generateAttributesSourceFile(metadata: [SourceFile], attributesPath: String, jsonPath: String) throws {
    var content = ""
    
    var count = 0
    
    content += "import Cocoa\n"
    content += "\n"
    content += "func evaluateAttributes() -> [AnyObject] {\n"
    
    func generateAttribute(attribute: String) {
        content += "    let attribute\(count): AnyObject = " + attribute + "\n"
        content += "\n"
        count++
    }
    
    for fc in metadata {
        for declaration in fc.declarations {
            switch declaration {
            case .Interface(let interface):
                for a in interface.serializedAttributes {
                    generateAttribute(a)
                }
                
                for p in interface.properties {
                    for a in p.serializedAttributes {
                        generateAttribute(a)
                    }
                }
            default: break
            }
        }
    }
    
    content += "    return [\n"
    for i in 0 ..< count {
    content += "        attribute\(i),\n"
    }
    content += "    ] as [AnyObject]\n"
    
    content += "}\n"
    content += "public func main() -> Int32 {\n"
    content += "    ModuleMetadata.generate(\"\(jsonPath)\", attributes: evaluateAttributes()) \n"
    content += "    return 0\n"
    content += "}\n"
    content += "exit(main())\n"
    
    try content.writeToFile(attributesPath, atomically: true, encoding: NSUTF8StringEncoding)
}

func main() -> Int {
    do {
        let args = Process.arguments
        
        let rootDirectory = args.count == 2 ? args[1] : "."
        
        let (parsedFiles, metadataFiles) = try parseFiles(rootDirectory)
        
        let serializedMetadata = try serializeToJson(parsedFiles)
        
        let metadataJsonPath = tempDir.stringByAppendingPathComponent("metadata.json")
        let attributesCodePath = tempDir.stringByAppendingPathComponent("main.swift")
        
        serializedMetadata.writeToFile(metadataJsonPath, atomically: true)
        
        try generateAttributesSourceFile(parsedFiles, attributesPath: attributesCodePath, jsonPath: metadataJsonPath)
        
        runMetadataProgramWithMetadataPath(metadataJsonPath,
            attributesFilePath: attributesCodePath,
            metadataSourceCodePaths: metadataFiles
        )
    }
    catch let e {
        print(e)
        exit(-1)
    }
    
    return 0
}

let _ = main()
