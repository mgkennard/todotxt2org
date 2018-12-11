//
//  main.swift
//  todotxttoorg
//
//  Created by Matthew Kennard on 10/12/2018.
//  Copyright © 2018 Apps On The Move Limited. All rights reserved.
//

import Foundation

let converter = TodoTxtConverter()

let filenames = CommandLine.arguments.dropFirst()

if filenames.count == 0 {
    print("No files provided for conversion from todo.txt to Org mode.")
    exit(1)
}

for filename in CommandLine.arguments.dropFirst() {
    if let contents = try? String(contentsOfFile: filename) {
        let orgContents = converter.convert(input: contents)
        let newFilename = "\((filename as NSString).deletingPathExtension).org"
        do {
            try orgContents.write(toFile: newFilename, atomically: true, encoding: .utf8)
            print("Converted \(filename) to \(newFilename).")
        } catch {
            print("Error writing \(newFilename).")
        }
    } else {
        print("Error reading \(filename).")
    }
}

print("Done.")
