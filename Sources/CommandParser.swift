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
        noSuchCommand(String),
        optionNotAllowedHere(String)
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
    
    
    // MARK: Parsing
    
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
            printUsageFor(command)
            throw CommandError.requiresArguments(command)
            
        } catch CommandError.noOptions(let command) {
            printHelp("Error: command \'\(command.name)\' has no options.")
            printUsageFor(command)
            throw CommandError.noOptions(command)
            
        } catch CommandError.optionRequiresArgument(let command, let option) {
            printHelp("Error: expected argument for option \'\(option.name)\', but none found.")
            printUsageFor(command)
            throw CommandError.optionRequiresArgument(command: command, option: option)
            
        } catch CommandError.invalidArguments(let command) {
            printHelp("Error: invalid arguments for command \'\(command.name)\'")
            printUsageFor(command)
            throw CommandError.invalidArguments(command)
            
        } catch CommandError.noArgumentsOrSubCommands(let command) {
            printHelp("Error: command \'\(command.name)\' does not take arguments nor does it have any subcommands.")
            printUsageFor(command)
            throw CommandError.noArgumentsOrSubCommands(command)
        }
    }
    
    private func _parse(_ tokens : [String]) throws -> Command {
        guard !commands.isEmpty else { throw ParserError.noCommands }
        guard !tokens.isEmpty, tokens[0] != "" else { throw ParserError.commandNotSupplied }

        let command = try getCommand(tokens[0])
        let result = try parseCommand(command, tokens: tokens)
        return result.command
    }
    
    private func parseCommand(_ c : Command, tokens : [String]) throws -> (command : Command, remainingTokens : [String]) {
        var command = c
        var remainingTokens = tokens
        remainingTokens.remove(at: 0) // Remove command name
        
        if remainingTokens.isEmpty {
            guard !command.hasRequiredArguments else { throw CommandError.requiresArguments(command) }
            return (command, remainingTokens)
        }
        
        (command, remainingTokens) = try parseCommandTokens(command, tokens: remainingTokens)
        return (command,remainingTokens)
    }
    
    private func parseCommandTokens(_ c : Command, tokens : [String]) throws -> (command : Command, remainingTokens : [String]) {
        var command = c
        var remainingTokens = tokens
        
        // Options
        if isLongformOption(tokens[0]) {
            guard command.hasOptions else { throw CommandError.noOptions(command) }
            (command, remainingTokens) = try parseCommandOptions(command, args: remainingTokens)
        }
        
        if remainingTokens.isEmpty {
            guard !command.hasRequiredArguments else { throw CommandError.requiresArguments(command) }
            return (command, remainingTokens)
        }
        
        // Arguments
        if command.hasRequiredArguments {
            (command, remainingTokens) = try parseCommandArguments(command, args: remainingTokens)
            guard command.allArgumentsSet else { throw CommandError.invalidArguments(command) }
        } else {
            guard command.hasSubcommands else { throw CommandError.noArgumentsOrSubCommands(command) }
        }
        
        if remainingTokens.isEmpty {
            return (command, remainingTokens)
        }
        
        // Subcommands
        var subCommand = try command.getSubCommand(name: remainingTokens[0])
        (subCommand, remainingTokens) = try parseCommand(subCommand, tokens: remainingTokens)
        command.usedSubCommand = subCommand
        return (command, remainingTokens)
    }
    
    private func parseCommandOptions(_ c : Command, tkns : [String]) throws -> (command: Command, remainingTokens : [String]) {
        var command = c
        var tokens = tkns
        for t in tkns {
            guard t.firstChar == "-" else { break }
            let s = getOptionRaw(t)
            if optionHasArgument(t) {
                let v = getOptionArgument(t)
                try command.setOption(s, value: v)
            } else {
                try command.setOption(s)
            }
            tokens.remove(at: 0)
        }
        return (command, tokens)
    }
    
    //TODO: When parsing command arguments, check token is not an option
    private func parseCommandArguments(_ c : Command, tkns : [String]) throws -> (command: Command, remainingTokens : [String])  {
        var command = c
        var tokens = tkns
        for var arg in command.arguments {
            guard let argValue = tokens[safe:0] else { throw CommandError.invalidArguments(command) }
            guard argValue.firstChar != "-" else { throw ParserError.optionNotAllowedHere(argValue) }
            arg.value = argValue
            tokens.remove(at: 0)
        }
        return (command, tokens)
    }
    
    private func getCommand(_ name : String) throws -> Command {
        guard let c = commands.filter({ $0.name == name }).first else { throw ParserError.noSuchCommand(name) }
        return c
    }
    
    
    // MARK: Token logic
    
    func isLongformOption(_ string : String) -> Bool {
        guard string.characters.count >= 3 else { return false }
        return string.character(atIndex: 0) == "-"
            && string.character(atIndex: 1) == "-"
    }
    
    func getOptionRaw(_ string : String) -> String {
        return string.components(separatedBy: "=").first!
    }
    
    func optionHasArgument(_ string : String) -> Bool {
        return string.contains("=")
    }
    
    func getOptionArgument(_ string : String) -> String {
        return string.components(separatedBy: "=").last!
    }
    
    
    // MARK: Usage text & debug
    
    private func printCommands() {
        if printHelp {
            UsageInfoPrinter().printCommands(for: self)
        }
    }
    
    private func printUsageFor(_ c : Command) {
        if printHelp {
            UsageInfoPrinter().printUsage(for: c)
        }
    }
    
    private func printHelp(_ s : String) {
        if printHelp {
            print(s)
        }
    }
}
