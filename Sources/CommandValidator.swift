//
//  CommandValidator.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import Foundation

struct CommandValidator : HasDebugMode {
    
    var debugMode : Bool
    
    /**
     Thrown if the command model or any of it's option or argument models is invalid.
    */
    public enum ModelError : Error {
        case invalidCommand
    }
    
    func validateCommand(_ c : Command) throws {
        guard !c.name.contains(" ") else {
            printDebug("Error: Invalid command model \'\(c)\'.")
            printDebug("Command name: \'\(c.name)\'\nCommand names must not contain spaces.")
            throw ModelError.invalidCommand
        }
        guard c.name != "" else {
            printDebug("Error: Invalid command model \'\(c)\'.")
            printDebug("Command name: \'\(c.name)\'\nCommand name must not be empty.")
            throw ModelError.invalidCommand
        }
        try validateOptions(c)
        try validateArguments(c)
        try validateSubCommands(c)
    }
    
    func validateOptions(_ c : Command) throws {
        guard Set(c.optionNames).count == c.optionNames.count else {
            printDebug("Error: Invalid options for command model \'\(c)\'.")
            printDebug("Two or more options have the same name.")
            throw ModelError.invalidCommand
        }
        for o in c.options {
            guard !o.name.contains(" ") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not contain spaces.")
                throw ModelError.invalidCommand
            }
            guard !o.name.contains("-") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not contain hyphens.")
                throw ModelError.invalidCommand
            }
            guard o.name != "" else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not be empty.")
                throw ModelError.invalidCommand
            }
        }
    }
    
    func validateArguments(_ c : Command) throws {
        guard Set(c.argumentNames).count == c.argumentNames.count else {
            printDebug("Error: Invalid arguments for command model \'\(c)\'.")
            printDebug("Two or more arguments have the same name.")
            throw ModelError.invalidCommand
        }
        for a in c.arguments {
            guard !a.name.contains(" ") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not contain spaces.")
                throw ModelError.invalidCommand
            }
            guard !a.name.contains("-") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not contain hyphens.")
                throw ModelError.invalidCommand
            }
            guard a.name != "" else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not be empty.")
                throw ModelError.invalidCommand
            }
        }
    }
    
    func validateSubCommands(_ c : Command) throws {
        for subcmd in c.subCommands {
            try validateCommand(subcmd)
        }
    }
}
