//
//  UsageInfoPrinter.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 01/11/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public struct UsageInfoPrinter {
    
    public func printCommands(for parser : CommandParser) {
        guard !parser.commands.isEmpty else {
            print("No registered commands.")
            return
        }
        print("\nCOMMANDS:")
        for cmd in parser.commands {
            print("\t\(cmd.name)\t\(cmd.helptext)")
        }
    }
    
    public func printInfo(_ cmds : [Command]) {
        for c in cmds {
            printInfo(c)
        }
    }
    
    public func printInfo(_ cmd : Command) {
        print("\nCOMMAND:")
        print("\t\(cmd.name)\t\(cmd.helptext)")
        print("\nUSAGE:")
        print("\t\(cmd.name)", terminator:" ")
        for o in cmd.options {
            print("[\(o.longFormName)", terminator:"] ")
        }
        for a in cmd.arguments {
            print("<\(a.name)>", terminator: " ")
        }
        print("\n")
    }
}
