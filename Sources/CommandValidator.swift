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

    func validate(_ command : Command) throws {
        guard !command.name.contains(" ") else {
            printDebug("Error: Invalid command model \'\(command)\'.")
            printDebug("Command name: \'\(command.name)\'\nCommand names must not contain spaces.")
            throw CommandModelError.invalidCommand
        }
        guard command.name != "" else {
            printDebug("Error: Invalid command model \'\(command)\'.")
            printDebug("Command name: \'\(command.name)\'\nCommand name must not be empty.")
            throw CommandModelError.invalidCommand
        }
        if let command = command as? CommandWithOptions {
            try validateOptions(for: command)
        }
        if let command = command as? CommandWithArguments {
            try validateArguments(for: command)
        }
        if let command = command as? CommandWithSubCommands {
            try validateSubCommands(for: command)
        }
    }
    
    func validateOptions(for command : CommandWithOptions) throws {
        guard !command.options.options.isEmpty else {
            printDebug("Error: Command model \(command) conforms to protocol CommandWithOptions. Property 'options' must contain at least one option.")
            throw CommandModelError.invalidCommand
        }
        guard Set(command.optionNames).count == command.optionNames.count else {
            printDebug("Error: Invalid options for command model \'\(command)\'.")
            printDebug("Two or more options have the same name.")
            throw CommandModelError.invalidCommand
        }
        for o in command.options.options {
            guard !o.option.name.contains(" ") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(command)\'.")
                printDebug("Option names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !o.option.name.contains("-") else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(command)\'.")
                printDebug("Option names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard o.option.name != "" else {
                printDebug("Error: Invalid option model \'\(o)\' for command model \'\(command)\'.")
                printDebug("Option names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
    
    func validateArguments(for command : CommandWithArguments) throws {
        guard !command.arguments.isEmpty else {
            printDebug("Error: Command model \(command) conforms to protocol CommandWithArguments. Property 'arguments' must contain at least one argument.")
            throw CommandModelError.invalidCommand
        }
        guard Set(command.argumentNames).count == command.argumentNames.count else {
            printDebug("Error: Invalid arguments for command model \'\(command)\'.")
            printDebug("Two or more arguments have the same name.")
            throw CommandModelError.invalidCommand
        }
        for a in command.arguments {
            guard !a.name.contains(" ") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(command)\'.")
                printDebug("Argument names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !a.name.contains("-") else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(command)\'.")
                printDebug("Argument names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard a.name != "" else {
                printDebug("Error: Invalid argument model \'\(a)\' for command model \'\(command)\'.")
                printDebug("Argument names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
    }
    
    func validateSubCommands(for command : CommandWithSubCommands) throws {
        guard !command.subcommands.isEmpty else {
            printDebug("Error: Command model \(command) conforms to protocol CommandWithSubCommands. Property 'subcommands' must contain at least one subcommand.")
            throw CommandModelError.invalidCommand
        }
        for subcommand in command.subcommands.commands {
            try validate(subcommand)
        }
    }
}
