//
//  CommandParser.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 27/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

import Foundation

public enum ParserError : Error {
    case noCommands,
        duplicateCommand,
        commandNotSupplied,
        noSuchCommand(String),
        noOptions(Command),
        noSuchOption(command:Command, option:String),
        optionRequiresArgument(command:Command, option:Option),
        optionNotAllowedHere(command : Command, option : String),
        requiresArguments(Command),
        invalidArguments(Command),
        invalidArgumentOrSubCommand(Command),
        noSuchSubCommand(command:Command, subcommandName:String)
}

public protocol CommandParserDelegate {
    
    /**
     Called if there were no command line arguments supplied to your program.
     */
    func commandNotSupplied()
    
    /**
     Called if a command was parsed successfully.
     */
    func receivedCommand(command : Command)
}

public class CommandParser : HasDebugMode {

    internal var commands : [Command.Type] = []
    
    /**
     If `true`, prints debug information. Default value is `false`.
    */
    public var debugMode : Bool = false
    
    /**
     If true, prints command usage help. Default value is `true`.
     */
    public var printHelp : Bool = true
    
    /**
     If true, prints command usage info if user doesn't supply a command. Default value is `true`.
     */
    public var printHelpOnNoCommand : Bool = true
    
    public init() {}
    
    /**
     Register command models with the parser, so that when the user supplies command-line arguments
     to your program, they will be recognised and parsed into objects.
     
     - parameter commands: Classes or structs that conform to a `Command` protocol.
                            Use as follows:
     
                            register(GenerateCommand.self, HelpCommand.self, AnotherCommand.self)
     
     - throws:  `ParserError.duplicateCommand` if the command parser instance already has a
                command registered with the same name as a command.
                Or `CommandModelError.invalidCommand` if a command model or
                any of it's option or argument models is invalid.
     */
    public func register(_ commands : Command.Type...) throws {
        for c in commands {
            try register(c)
        }
    }
    
    private func register(_ command : Command.Type) throws {
        guard !commands.contains(where: { $0 == command }) else {
            printDebug("Error: Duplicate command model \'\(command)\'.")
            printDebug("CommandParser already has a registered command with name: \'\(command.name)\'")
            throw ParserError.duplicateCommand
        }
        try CommandValidator(debugMode: debugMode).validateCommand(command.init())
        commands.append(command)
    }
    
    
    // MARK: Parsing
    
    /**
     Parses the input from the CommandLine.
     
     - throws:  Errors of type `ParserError` if no commands are registered, or there 
                is a problem with parsing the command, or invalid arguments were supplied.
     */
    public func parseCommandLine(delegate : CommandParserDelegate?) throws {
        var args = CommandLine.arguments
        args.remove(at: 0)
        return try parse(arguments: args, delegate: delegate)
    }

    func parse(arguments : [String]) throws {
        return try parse(arguments: arguments, delegate: nil)
    }
    
    /**
     Parses the supplied input.
     
     - parameter arguments: The arguments to be parsed.
     - parameter delegate:  If a command is successfully parsed, the delegate's `receivedCommand` func
                            will be called. If the user doesn't supply a command, the delegate's
                            `commandNotSupplied` func will be called.
     
     - throws:  Errors of type `ParserError` if no commands are registered, or there
                is a problem with parsing the command, or invalid arguments were supplied.
    */
    public func parse(arguments : [String], delegate : CommandParserDelegate?) throws {
        
        do {
            let command = try _parse(arguments)
            if let d = delegate {
                d.receivedCommand(command: command)
            }
        } catch ParserError.noCommands {
            printDebug("Error: no commands registered with the parser.")
            throw ParserError.noCommands
            
        } catch ParserError.commandNotSupplied {
            if let d = delegate {
                d.commandNotSupplied()
            }
            if printHelpOnNoCommand {
                UsageInfoPrinter().printCommands(commands)
            }
            
        } catch ParserError.noSuchCommand(let name) {
            printHelp("Error: no such command \'\(name)\'")
            printCommands()
            throw ParserError.noSuchCommand("\(name)")
            
        } catch ParserError.noOptions(let command) {
            printHelp("Error: command \'\(type(of:command).name)\' has no options.")
            printUsageFor(command)
            throw ParserError.noOptions(command)
            
        } catch CommandError.noSuchOption(let command, let option) {
            printDebug("Error: command \'\(type(of:command).name)\' has no such option: \'\(option)\'")
            throw ParserError.noSuchOption(command: command, option: option)
            
        } catch ParserError.optionNotAllowedHere(let command, let option) {
            printHelp("Error: An option \'\(option)\' for command \'\(type(of:command).name)\' was found," +
                "but it is not allowed here. Options must come before a command's required arguments.")
            printUsageFor(command)
            throw ParserError.optionNotAllowedHere(command: command, option: option)
            
        } catch CommandError.optionRequiresArgument(let command, let option) {
            printHelp("Error: expected argument for option \'\(option.name)\', but none found.")
            printUsageFor(command)
            throw ParserError.optionRequiresArgument(command: command, option: option)
            
        } catch ParserError.requiresArguments(let command) {
            printHelp("Error: command \'\(type(of:command).name)\' has required arguments but none were supplied.")
            printUsageFor(command)
            throw ParserError.requiresArguments(command)

        } catch ParserError.invalidArguments(let command) {
            printHelp("Error: invalid arguments for command \'\(type(of:command).name)\'")
            printUsageFor(command)
            throw ParserError.invalidArguments(command)
            
        } catch ParserError.invalidArgumentOrSubCommand(let command) {
            printHelp("Error: command \'\(type(of:command).name)\' does not take arguments nor does it have any subcommands.")
            printUsageFor(command)
            throw ParserError.invalidArgumentOrSubCommand(command)
            
        } catch CommandError.noSuchSubCommand(let command, let subcommandName) {
            printHelp("Error: command \'\(type(of:command).name)\' has no subcommand: \'\(subcommandName)\'")
            printUsageFor(command)
            throw ParserError.noSuchSubCommand(command:command, subcommandName:subcommandName)
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
            guard !(command is CommandWithArguments) else { throw ParserError.requiresArguments(command) }
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
            guard let c = command as? CommandWithOptions else { throw ParserError.noOptions(command) }
            (command, remainingTokens) = try parseCommandOptions(c, tkns: remainingTokens)
        }
        // Arguments
        if let c = command as? CommandWithArguments {
            (command, remainingTokens) = try parseCommandArguments(c, tkns: remainingTokens)
            guard (command as! CommandWithArguments).allArgumentsSet else { throw ParserError.invalidArguments(command) }
        }
        // SubCommands
        if let c = command as? CommandWithSubCommands {
            (command, remainingTokens) = try parseSubCommand(c, tkns: remainingTokens)
        }
        guard remainingTokens.isEmpty else { throw ParserError.invalidArgumentOrSubCommand(command) }
        return (command, remainingTokens)
    }
    
    private func parseCommandOptions(_ c : CommandWithOptions, tkns : [String]) throws -> (command: Command, remainingTokens : [String]) {
        var command = c
        var tokens = tkns
        for t in tkns {
            guard t.firstChar == "-" else { break }
            let s = getOptionName(t)
            if optionHasArgument(t) {
                try command.setOption(s, value: getOptionArgument(t))
            } else {
                try command.setOption(s)
            }
            tokens.remove(at: 0)
        }
        return (command, tokens)
    }
    
    private func parseCommandArguments(_ c : CommandWithArguments, tkns : [String]) throws -> (command: Command, remainingTokens : [String])  {
        var command = c
        var tokens = tkns
        for var arg in command.arguments {
            guard let argValue = tokens[safe:0] else { throw ParserError.invalidArguments(command) }
            guard argValue.firstChar != "-" else { throw ParserError.optionNotAllowedHere(command: command, option: argValue) }
            arg.value = argValue
            tokens.remove(at: 0)
        }
        return (command, tokens)
    }
    
    private func parseSubCommand(_ c : CommandWithSubCommands, tkns : [String]) throws -> (command: Command, remainingTokens : [String]) {
        var command = c
        var tokens = tkns
        var subcommand = try command.getSubCommand(name: tokens[0])
        (subcommand, tokens) = try parseCommand(subcommand, tokens: tokens)
        command.usedSubcommand = subcommand
        return (command, tokens)
    }
    
    private func getCommand(_ name : String) throws -> Command {
        guard let c = commands.filter({ $0.name == name }).first else { throw ParserError.noSuchCommand(name) }
        return c.init()
    }
    
    // MARK: Token logic
    
    func isLongformOption(_ string : String) -> Bool {
        guard string.characters.count >= 3 else { return false }
        return string.character(atIndex: 0) == "-"
            && string.character(atIndex: 1) == "-"
    }
    
    func getOptionName(_ string : String) -> String {
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
            UsageInfoPrinter().printCommands(commands)
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
