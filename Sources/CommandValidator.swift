//
//  CommandValidator.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import Foundation

/**
 Thrown if the command model or any of it's option or argument models is invalid.
 */
public enum CommandModelError : Error {
    case invalidCommand
}

struct CommandValidator : HasDebugMode {
    
    var debugMode : Bool
    
    /**
     Checks if the command model and it's `Option` and `Argument` models are suitable for
     use with the parser.
     
     - throws: a `CommandModelError` if the command model or any of it's option or argument models is invalid.
     - parameter c: The command to be validated.
     */
    public func validateCommand(_ c : Command) throws {
        guard !c.name.contains(" ") else {
            printDebug("Error: Invalid command model \'\(c)\'.")
            printDebug("Command name: \'\(c.name)\'\nCommand names must not contain spaces.")
            throw CommandModelError.invalidCommand
        }
        guard c.name != "" else {
            printDebug("Error: Invalid command model \'\(c)\'.")
            printDebug("Command name: \'\(c.name)\'\nCommand name must not be empty.")
            throw CommandModelError.invalidCommand
        }
        try validateOptions(c)
        try validateArguments(c)
    }
    
    private func validateOptions(_ c : Command) throws {
        guard Set(c.optionNames).count == c.optionNames.count else {
            printDebug("Error: Invalid options for command model \'\(c)\'.")
            printDebug("Two or more options have the same name.")
            throw CommandModelError.invalidCommand
        }
        for o in c.options {
            guard !o.name.contains(" ") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !o.name.contains("-") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard o.name != "" else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                printDebug("Option names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
    
    private func validateArguments(_ c : Command) throws {
        guard Set(c.argumentNames).count == c.argumentNames.count else {
            printDebug("Error: Invalid arguments for command model \'\(c)\'.")
            printDebug("Two or more arguments have the same name.")
            throw CommandModelError.invalidCommand
        }
        for a in c.arguments {
            guard !a.name.contains(" ") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !a.name.contains("-") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard a.name != "" else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                printDebug("Argument names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
}
