//
//  CommandValidator.swift
//  SwiftArgs
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

    func validateCommand(_ c : Command) throws {
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
        if let cmd = c as? CommandWithSubCommands {
            try validateSubCommands(cmd)
        }
    }
    
    func validateOptions(_ c : Command) throws {
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
    
    func validateArguments(_ c : Command) throws {
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
    
    func validateSubCommands(_ c : CommandWithSubCommands) throws {
        guard !c.subCommands.isEmpty else {
            printDebug("Error: Command model \(c) conforms to protocol CommandWithSubCommands. Property 'subCommands' must contain at least one subcommand")
            throw CommandModelError.invalidCommand
        }
        for subcmd in c.subCommands {
            try validateCommand(subcmd)
        }
    }
}
