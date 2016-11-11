//
//  UsageInfoPrinter.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 01/11/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public struct UsageInfoPrinter {
    
    public func printCommands(_ cmds : [Command]) {
        guard !cmds.isEmpty else { return } // No registered commands
        print("\nCOMMANDS:")
        _printNameAndHelpText(for: cmds)
        print("")
    }
    
    public func printHelpAndUsage(for command : Command) {
        print("\nCOMMAND:")
        _printNameAndHelpText(for: command)
        print("\nUSAGE:")
        _printCommandUsage(command)
        print("\n")
    }
    
    public func printUsage(for command : Command) {
        print("\nUSAGE:")
        _printCommandUsage(command)
        print("\n")
    }
    
    private func _printNameAndHelpText(for cmds : [Command]) {
        for c in cmds {
            _printNameAndHelpText(for: c)
        }
    }
    
    private func _printNameAndHelpText(for cmd: Command) {
        print("    \(cmd.name)    \(cmd.helptext)")
    }
    
    private func _printCommandUsage(_ cmd : Command) {
        print("    \(cmd.name)", terminator:" ")
        for o in cmd.options {
            print("[\(o.longFormName)", terminator:"] ")
        }
        for a in cmd.arguments {
            print("<\(a.name)>", terminator: " ")
        }
    }
}
