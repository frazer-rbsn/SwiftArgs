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

    //TODO: Rename according to Swift API guidelines
    func validateCommand(_ cmd: Command) throws {
        guard !cmd.name.contains(" ") else {
            printDebug("Error: Invalid command model \'\(cmd)\'.")
            printDebug("Command name: \'\(cmd.name)\'\nCommand names must not contain spaces.")
            throw CommandModelError.invalidCommand
        }
        guard cmd.name != "" else {
            printDebug("Error: Invalid command model \'\(cmd)\'.")
            printDebug("Command name: \'\(cmd.name)\'\nCommand name must not be empty.")
            throw CommandModelError.invalidCommand
        }
        if let c = cmd as? CommandWithOptions {
            try validateOptions(c)
        }
        try validateArguments(cmd)
        if let c = cmd as? CommandWithSubCommands {
            try validateSubCommands(c)
        }
    }
    
    func validateOptions(_ cmd : CommandWithOptions) throws {
        guard !cmd.options.isEmpty else {
            printDebug("Error: Command model \(cmd) conforms to protocol CommandWithOptions. Property 'options' must contain at least one option.")
            throw CommandModelError.invalidCommand
        }
        guard Set(cmd.optionNames).count == cmd.optionNames.count else {
            printDebug("Error: Invalid options for command model \'\(cmd)\'.")
            printDebug("Two or more options have the same name.")
            throw CommandModelError.invalidCommand
        }
        for o in cmd.options {
            guard !o.name.contains(" ") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(cmd)\'.")
                printDebug("Option names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !o.name.contains("-") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(cmd)\'.")
                printDebug("Option names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard o.name != "" else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(cmd)\'.")
                printDebug("Option names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
    
    func validateArguments(_ cmd : Command) throws {
        guard Set(cmd.argumentNames).count == cmd.argumentNames.count else {
            printDebug("Error: Invalid arguments for command model \'\(cmd)\'.")
            printDebug("Two or more arguments have the same name.")
            throw CommandModelError.invalidCommand
        }
        for a in cmd.arguments {
            guard !a.name.contains(" ") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(cmd)\'.")
                printDebug("Argument names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !a.name.contains("-") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(cmd)\'.")
                printDebug("Argument names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard a.name != "" else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(cmd)\'.")
                printDebug("Argument names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
    
    func validateSubCommands(_ cmd : CommandWithSubCommands) throws {
        guard !cmd.subCommands.isEmpty else {
            printDebug("Error: Command model \(cmd) conforms to protocol CommandWithSubCommands. Property 'subCommands' must contain at least one subcommand.")
            throw CommandModelError.invalidCommand
        }
        for subcmd in cmd.subCommands {
            try validateCommand(subcmd)
        }
    }
}
