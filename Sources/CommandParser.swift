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
            print("Error: Invalid command model \'\(c)\'.")
            print("Command name: \'\(c.name)\'\nCommand names must not contain spaces.")
            throw CommandModelError.invalidCommand
        }
        guard c.name != "" else {
            print("Error: Invalid command model \'\(c)\'.")
            print("Command name: \'\(c.name)\'\nCommand name must not be empty.")
            throw CommandModelError.invalidCommand
        }
        for o in c.options {
            guard !o.name.contains(" ") else {
                print("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                print("Option names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !o.name.contains("-") else {
                print("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                print("Option names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard o.name != "" else {
                print("Error: Invalid option model \'\(o)\' for command model \'\(c)\'.")
                print("Option names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
        for a in c.arguments {
            guard !a.name.contains(" ") else {
                print("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                print("Argument names must not contain spaces.")
                throw CommandModelError.invalidCommand
            }
            guard !a.name.contains("-") else {
                print("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                print("Argument names must not contain hyphens.")
                throw CommandModelError.invalidCommand
            }
            guard a.name != "" else {
                print("Error: Invalid argument model \'\(a)\' for command model \'\(c)\'.")
                print("Argument names must not be empty.")
                throw CommandModelError.invalidCommand
            }
        }
        
        // Duplication checks
        
        guard !commands.contains(where: { $0 == c }) else {
            print("Error: Duplicate command model \'\(c)\'.")
            print("CommandParser already has a registered command with name: \'\(c.name)\'")
            throw CommandModelError.invalidCommand
        }
        
        guard Set(c.optionNames).count == c.optionNames.count else {
            print("Error: Invalid options for command model \'\(c)\'.")
            print("Two or more options have the same name.")
            throw CommandModelError.invalidCommand
        }
        
        guard Set(c.argumentNames).count == c.argumentNames.count else {
            print("Error: Invalid arguments for command model \'\(c)\'.")
            print("Two or more arguments have the same name.")
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
        return try parse(args: CommandLine.argumentsWithoutFilename)
    }
    
    /**
     Parses the supplied input and returns a `Command` object if successful.
     - parameter args: The arguments to be parsed.
     - throws:  `ParserError` if no commands are registered or there is a problem with 
                parsing the command.
                Or `CommandError` if a valid command was supplied but invalid 
                arguments/options were supplied.
    */
    public func parse(args : [String]) throws -> Command {
        do {
            let command = try _parse(args)
            return command
            
        } catch ParserError.noCommands {
            print("Error: no commands registered with the parser.")
            throw ParserError.noCommands
            
        } catch ParserError.commandNotSupplied {
            printUsageInfo()
            throw ParserError.commandNotSupplied
            
        } catch ParserError.noSuchCommand(let name) {
            print("Error: no such command \'\(name)\'\n")
            printUsageInfo()
            throw ParserError.noSuchCommand("\(name)")

        } catch CommandError.requiresArguments(let name) {
            print("Error: command \'\(name)\' has required arguments but none were supplied.")
            printUsageInfo()
            throw CommandError.requiresArguments("\(name)")
            
        } catch CommandError.noOptions(let name) {
            print("Error: command \'\(name)\' has no options.")
            printUsageInfo()
            throw CommandError.noOptions("\(name)")
            
        } catch CommandError.optionRequiresArgument(let name) {
            print("Error: expected argument for option \'\(name)\', but none found.")
            printUsageInfo()
            throw CommandError.optionRequiresArgument("\(name)")
            
        } catch CommandError.invalidArguments(let name, let args) {
            print("Error: invalid arguments for command \'\(name)\': \(args)")
            printUsageInfo()
            throw CommandError.invalidArguments(commandName: "\(name)",suppliedArguments: args)
            
        } catch CommandError.noArguments(let name) {
            print("Error: command \'\(name)\' does not take arguments.")
            throw CommandError.noArguments("\(name)")
        }
    }
    
    private func _parse(_ arguments : [String]) throws -> Command {
        guard !commands.isEmpty else { throw ParserError.noCommands }
        guard !arguments.isEmpty else { throw ParserError.commandNotSupplied }
        
        let cmdString = arguments[0]
        guard cmdString != "" else { throw ParserError.commandNotSupplied }
        
        var command = try getCommand(cmdString)
        var args = arguments
        args.remove(at: 0) // Remove command from args
        
        if args.isEmpty {
            guard !command.hasRequiredArguments else { throw CommandError.requiresArguments(command.name) }
            printUsageInfo()
            return command
        }
        
        // If options were supplied, parse options
        if isLongformOption(args[0]) {
            guard command.hasOptions else { throw CommandError.noOptions(command.name) }
            (command, args) = try parseCommandOptions(command, args: args)
        } else {
            guard command.hasRequiredArguments else { throw CommandError.noArguments(command.name) }
        }
        
        command = try parseCommandArguments(command, args: args)
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
                else { throw CommandError.invalidArguments(commandName: command.name, suppliedArguments: args) }
            a.value = argValue
            arguments.remove(at: 0)
        }
        guard arguments.isEmpty else { throw CommandError.invalidArguments(commandName: command.name, suppliedArguments: args) }
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
    
    private func printUsageInfo() {
        UsageInfoPrinter().printInfo(commands)
    }
}
