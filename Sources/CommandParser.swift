//
//  CommandParser.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 27/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public class CommandParser : HasDebugMode {

    internal var commands : [Command] = []
    
    /**
     If `true`, prints debug information. Default value is `false`.
    */
    public var debugMode : Bool = false
    
    /**
     If true, prints command usage help. Default value is `true`.
     */
    public var printHelp : Bool = true
    
    public enum ParserError : Error {
        case duplicateCommand,
        noCommands,
        commandNotSupplied,
        noSuchCommand(String)
    }
    
    /**
     Register a command with the parser, so that when the user supplies command line arguments 
     to your program, they will be recognised and parsed into objects.
     - throws:  `PaserError.duplicateCommand` if the command parser instance already has a command registered
                with the same name as the command.
                Or `CommandValidator.ModelError` if the command model or any of it's option or
                argument models is invalid.
     - parameter c: The command to be registered with the parser.
     */
    public func addCommand(_ c : Command) throws {
        guard !commands.contains(where: { $0 == c }) else {
            printDebug("Error: Duplicate command model \'\(c)\'.")
            printDebug("CommandParser already has a registered command with name: \'\(c.name)\'")
            throw ParserError.duplicateCommand
        }
        try CommandValidator(debugMode: debugMode).validateCommand(c)
        commands.append(c)
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
