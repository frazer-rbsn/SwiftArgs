//
//  CLExtensions.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 01/11/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public extension CommandLine {
    
    public static var argumentsWithoutFilename : [String] {
        var args = CommandLine.arguments
        args.remove(at: 0)
        return args
    }
    
}
