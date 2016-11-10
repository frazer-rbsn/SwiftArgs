//
//  CommandParser.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 27/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public class CommandParser {

    internal var commands : [Command] = []
    
    /**
     If `true`, prints debug information. Default value is `false`.
    */
    public var debugMode : Bool = false
    
    /**
     If true, prints command usage help. Default value is `true`.
     */
    public var printHelp : Bool = true
    
    /**
     Register a command with the parser, so that when the user supplies command line arguments 
     to your program, they will be recognised and parsed into objects.
     - throws: a `CommandModelError` if the command model or any of it's option or argument models is invalid.
     - parameter c: The command to be registered with the parser.
     */
    public func addCommand(_ c : Command) throws {
        try validateCommand(c)
        commands.append(c)
    }
    
    /**
     Thrown if the command models are valid but the parser 
     is supplied invalid arguments at runtime.
     */
    public enum ParserError : Error {
        case noSuchCommand(String),
        noCommands,
        commandNotSupplied
    }
    
    /**
     Thrown if the command model or any of it's option or argument models is invalid.
     */
    public enum CommandModelError : Error {
        case invalidCommand
    }
    
    /**
     Checks if the command model and it's `Option` and `Argument` models are suitable for 
     use with the parser.
     
     - throws: a `CommandModelError` if the command model or any of it's option or argument models is invalid.
     - parameter c: The command to be validated.
    */
    public func validateCommand(_ c : Command) throws {
        
        // Name checks
        
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
        
        // Duplication checks
        
        guard !commands.contains(where: { $0 == c }) else {
            printDebug("Error: Duplicate command model \'\(c)\'.")
            printDebug("CommandParser already has a registered command with name: \'\(c.name)\'")
            throw CommandModelError.invalidCommand
        }
        
        guard Set(c.optionNames).count == c.optionNames.count else {
            printDebug("Error: Invalid options for command model \'\(c)\'.")
            printDebug("Two or more options have the same name.")
            throw CommandModelError.invalidCommand
        }
        
        guard Set(c.argumentNames).count == c.argumentNames.count else {
            printDebug("Error: Invalid arguments for command model \'\(c)\'.")
            printDebug("Two or more arguments have the same name.")
            throw CommandModelError.invalidCommand
        }
    }
    
    /**
     Parses the input from the CommandLine and returns a `Command` object if successful.
     - throws:  `ParserError` if no commands are registered or there is a problem with 
                parsing the command.
                Or `CommandError` if a valid command was supplied but invalid 
                arguments/options were supplied.
     */
    public func parseCommandLine() throws -> Command {
        return try parse(arguments: CommandLine.argumentsWithoutFilename)
    }
    
    /**
     Parses the supplied input and returns a `Command` object if successful.
     - parameter args: The arguments to be parsed.
     - throws:  `ParserError` if no commands are registered or there is a problem with 
                parsing the command.
                Or `CommandError` if a valid command was supplied but invalid 
                arguments/options were supplied.
    */
    public func parse(arguments : [String]) throws -> Command {
        do {
            let command = try _parse(arguments)
            return command
            
        } catch ParserError.noCommands {
            printDebug("Error: no commands registered with the parser.")
            throw ParserError.noCommands
            
        } catch ParserError.noSuchCommand(let name) {
            printHelp("Error: no such command \'\(name)\'")
            printCommands()
            throw ParserError.noSuchCommand("\(name)")

        } catch CommandError.requiresArguments(let command) {
            printHelp("Error: command \'\(command.name)\' has required arguments but none were supplied.")
            printUsageInfoForCommand(command)
            throw CommandError.requiresArguments(command)
            
        } catch CommandError.noOptions(let command) {
            printHelp("Error: command \'\(command.name)\' has no options.")
            printUsageInfoForCommand(command)
            throw CommandError.noOptions(command)
            
        } catch CommandError.optionRequiresArgument(let command, let option) {
            printHelp("Error: expected argument for option \'\(option.name)\', but none found.")
            printUsageInfoForCommand(command)
            throw CommandError.optionRequiresArgument(command: command, option: option)
            
        } catch CommandError.invalidArguments(let command) {
            printHelp("Error: invalid arguments for command \'\(command.name)\': \(arguments)")
            printUsageInfoForCommand(command)
            throw CommandError.invalidArguments(command)
            
        } catch CommandError.noArguments(let command) {
            printHelp("Error: command \'\(command.name)\' does not take arguments.")
            printUsageInfoForCommand(command)
            throw CommandError.noArguments(command)
        }
    }
    
    private func _parse(_ args : [String]) throws -> Command {
        guard !commands.isEmpty else { throw ParserError.noCommands }
        guard !args.isEmpty else { throw ParserError.commandNotSupplied }
        
        let cmdString = args[0]
        guard cmdString != "" else { throw ParserError.commandNotSupplied }
        
        var command = try getCommand(cmdString)
        var arguments = args
        arguments.remove(at: 0) // Remove command from args
        
        if arguments.isEmpty {
            guard !command.hasRequiredArguments else { throw CommandError.requiresArguments(command) }
            return command
        }
        
        // If options were supplied, parse options
        if isLongformOption(arguments[0]) {
            guard command.hasOptions else { throw CommandError.noOptions(command) }
            (command, arguments) = try parseCommandOptions(command, args: arguments)
        } else {
            guard command.hasRequiredArguments else { throw CommandError.noArguments(command) }
        }
        
        command = try parseCommandArguments(command, args: arguments)
        return command
    }
    
    private func parseCommandOptions(_ c : Command, args : [String]) throws -> (command: Command, arguments : [String]) {
        var command = c
        var arguments = args
        for a in args {
            guard a.firstChar == "-" else { break }
            let s = getOptionRaw(a)
            if optionHasArgument(a) {
                let v = getOptionArgument(a)
                try command.setOption(s, value: v)
            } else {
                try command.setOption(s)
            }
            arguments.remove(at: 0)
        }
        return (command, arguments)
    }
    
    private func parseCommandArguments(_ c : Command, args : [String]) throws -> Command {
        var command = c
        var arguments = args
        for var a in command.arguments {
            guard let argValue = arguments[safe:0]
                else { throw CommandError.invalidArguments(command) }
            a.value = argValue
            arguments.remove(at: 0)
        }
        guard arguments.isEmpty else { throw CommandError.invalidArguments(command) }
        return command
    }
    
    private func getCommand(_ arg : String) throws -> Command {
        guard let c = commands.filter({ $0.name == arg }).first else { throw ParserError.noSuchCommand(arg) }
        return c
    }
    
    func isLongformOption(_ string : String) -> Bool {
        guard string.characters.count >= 3 else { return false }
        return string.character(atIndex: 0) == "-"
            && string.character(atIndex: 1) == "-"
    }
    
    func getOptionRaw(_ string : String) -> String {
        return string.components(separatedBy: "=").first!
    }
    
    private func optionHasArgument(_ string : String) -> Bool {
        return string.contains("=")
    }
    
    func getOptionArgument(_ string : String) -> String {
        return string.components(separatedBy: "=").last!
    }
    
    private func printDebug(_ s : String) {
        if debugMode {
            print(s)
        }
    }
    
    private func printCommands() {
        if printHelp {
            UsageInfoPrinter().printCommands(for: self)
        }
    }
    
    private func printUsageInfoForCommand(_ c : Command) {
        if printHelp {
            UsageInfoPrinter().printHelpAndUsage(for: c)
        }
    }
    
    private func printHelp(_ s : String) {
        if printHelp {
            print(s)
        }
    }
}
