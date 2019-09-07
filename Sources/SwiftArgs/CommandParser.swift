//
//  CommandParser.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 27/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

import Foundation

public enum CommandParserError : Error {
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
   Called if there was a problem.
   */
  func parserError(error : CommandParserError)
  
  /**
   Called if there were no command-line arguments supplied to your program.
   */
  func commandNotSupplied()
  
  /**
   Called if a command was parsed successfully.
   */
  func receivedCommand(command : Command)
}

/**
 Receives and processes arguments sent to your program.
 
 How to use:
 
 1. Create an object that conforms to the `CommandParserDelegate` protocol.
 2. Create a `CommandParser` instance
 3. Add your command models to the parser using `CommandParser.register(_:)`
 4. Call `CommandParser.parseCommandLine(delegate:)` and pass your delegate object.
 5. For possible errors that can be received by `CommandParserDelegate.parserError(_:)`, see `CommandParserError`
 */
public final class CommandParser : HasDebugMode {
  
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
  
  var register : CommandRegister = CommandRegister()
  
  public init() {}
  
  /**
   Register command models with the parser, so that when the user supplies command-line arguments
   to your program, they will be recognised and parsed into objects.
   
   - parameter commands:  Classes or structs that conform to a `Command` protocol.
   
   Use as follows:
   
   ````
   register(GenerateCommand.self, HelpCommand.self, AnotherCommand.self)
   ````
   
   - throws:  `ParserError.duplicateCommand` if the command parser instance already has a
   command registered with the same name as a command.
   Or `CommandModelError.invalidCommand` if a command model or
   any of it's option or argument models is invalid.
   */
  public func register(_ commands : Command...) throws {
    for c in commands {
      try register.insert(c)
    }
  }
  
  /**
   Register command names with the parser, so that when the user supplies command-line arguments
   to your program, they will be recognised and parsed into objects.
   
   - parameter commandNames:  Each string will correspond to a command keyboard.
   
   Use as follows:
   ````
   register("run", "help", "new")
   ````
   
   - throws:  `ParserError.duplicateCommand` if the command parser instance already has a
   command registered with the same name as a command.
   Or `CommandModelError.invalidCommand` if a command model or
   any of it's option or argument models is invalid.
   */
  public func register(_ commandNames : String...) throws {
    try register.insert(commandNames)
  }
  
  
  // MARK: Parsing
  
  /**
   Parses the input from the CommandLine.
   
   Calls `delegate.parserError(error : CommandParserError)` if no commands are registered, or there
   is a problem with parsing the command, or invalid arguments were supplied.
   */
  public func parseCommandLine(delegate : CommandParserDelegate?) {
    var args = CommandLine.arguments
    args.remove(at: 0)
    parse(arguments: args, delegate: delegate)
  }
  
  func parse(arguments : [String]) {
    parse(arguments: arguments, delegate: nil)
  }
  
  private func parserErrorThrown(error : Error, delegate : CommandParserDelegate?) {
    if let error = error as? CommandParserError {
      switch error {
      case .noCommands:
        printDebug("Error: no commands registered with the parser.")
      case .commandNotSupplied:
        delegate?.commandNotSupplied()
        register.printCommands()
        return
      case .noSuchCommand(let name):
        printHelp("Error: no such command '\(name)'")
        register.printCommands()
      case .noOptions(let command):
        printHelp("Error: command \'\(command.name)\' has no options.")
        printUsageFor(command)
      case .optionNotAllowedHere(let command, let option):
        printHelp("Error: An option \'\(option)\' for command \'\(command.name)\' was found," +
          "but it is not allowed here. Options must come before a command's required arguments.")
        printUsageFor(command)
      case .requiresArguments(let command):
        printHelp("Error: command \'\(command.name)\' has required arguments but none were supplied.")
        printUsageFor(command)
      case .invalidArguments(let command):
        printHelp("Error: invalid arguments for command \'\(command.name)\'")
        printUsageFor(command)
      case .invalidArgumentOrSubCommand(let command):
        printHelp("Error: command \'\(command.name)\' does not take arguments nor does it have any subcommands.")
        printUsageFor(command)
      default: fatalError() //TODO:
      }
      delegate?.parserError(error: error)
    } else if let error = error as? CommandError {
      switch error {
      case .noSuchOption(let command, let option):
        printDebug("Error: command \'\(command.name)\' has no such option: \'\(option)\'")
        delegate?.parserError(error: .noSuchOption(command: command, option: option))
      case .noSuchSubCommand(let command, let subcommandName):
        printHelp("Error: command \'\(command.name)\' has no such subcommand: \'\(subcommandName)\'")
        printUsageFor(command)
        delegate?.parserError(error: .noSuchSubCommand(command: command, subcommandName: subcommandName))
      case .optionRequiresArgument(let command, let option):
        printHelp("Error: command \'\(command.name)\' with option \'\(option.name)\' has required arguments but none were supplied.")
        printUsageFor(command)
        delegate?.parserError(error: .optionRequiresArgument(command: command, option: option))
      }
    }
  }
  
  /**
   Parses the supplied input.
   
   - parameter arguments: The arguments to be parsed.
   - parameter delegate:  If a command is successfully parsed, the delegate's `receivedCommand` func
   will be called. If the user doesn't supply a command, the delegate's
   `commandNotSupplied` func will be called.
   
   Calls `delegate.parserError(error : CommandParserError)` if no commands are registered, or there
   is a problem with parsing the command, or invalid arguments were supplied.
   */
  public func parse(arguments : [String], delegate : CommandParserDelegate?) {
    do {
      let command = try _parse(arguments)
      if let d = delegate {
        d.receivedCommand(command: command)
      }
    } catch {
      parserErrorThrown(error: error, delegate: delegate)
    }
  }
  
  private func _parse(_ tokens : [String]) throws -> Command {
    guard !register.isEmpty else { throw CommandParserError.noCommands }
    guard !tokens.isEmpty, tokens[0] != "" else { throw CommandParserError.commandNotSupplied }
    
    let command = try register.getCommand(tokens[0])
    let result = try parseCommand(command, tokens: tokens)
    return result.command
  }
  
  private func parseCommand(_ c : Command, tokens : [String]) throws -> (command : Command, remainingTokens : [String]) {
    var command = c
    var remainingTokens = tokens
    remainingTokens.remove(at: 0) // Remove command name
    
    if remainingTokens.isEmpty {
      guard !(command is CommandWithArguments) else { throw CommandParserError.requiresArguments(command) }
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
      guard let c = command as? CommandWithOptions else { throw CommandParserError.noOptions(command) }
      (command, remainingTokens) = try parseCommandOptions(c, remainingTokens)
    }
    // Arguments
    if let c = command as? CommandWithArguments {
      (command, remainingTokens) = try parseCommandArguments(c, remainingTokens)
      guard (command as! CommandWithArguments).allArgumentsSet else { throw CommandParserError.invalidArguments(command) }
    }
    // SubCommands
    if let c = command as? CommandWithSubCommands {
      (command, remainingTokens) = try parseSubCommand(c, remainingTokens)
    }
    guard remainingTokens.isEmpty else { throw CommandParserError.invalidArgumentOrSubCommand(command) }
    return (command, remainingTokens)
  }
  
  private func parseCommandOptions(_ c : CommandWithOptions, _ tkns : [String]) throws -> (command: Command, remainingTokens : [String]) {
    var command = c
    var tokens = tkns
    for t in tokens {
      guard tokens.firstIndex(of: t) != nil else { break } // Check this element hasn't been removed. We're looping through a buffer, not the actual array.
      guard t.firstChar == "-" else { break }
      let s = getOptionName(t)
      let o = try command.getOption(s)
      if o is OptionWithArgument {
        if t.contains("=") {
          try command.setOption(s, value: t.components(separatedBy: "=").last!)
        } else {
          let i = tokens.index(after: tokens.firstIndex(of: t)!)
          try command.setOption(s, value: tokens[safe:UInt(i)])
          tokens.remove(at: i)
        }
      } else {
        try command.setOption(s)
      }
      tokens.remove(at: 0)
    }
    return (command, tokens)
  }
  
  private func parseCommandArguments(_ c : CommandWithArguments, _ tkns : [String]) throws -> (command: Command, remainingTokens : [String])  {
    let command = c
    var tokens = tkns
    for var arg in command.arguments {
      guard let argValue = tokens[safe:0] else { throw CommandParserError.invalidArguments(command) }
      guard argValue.firstChar != "-" else { throw CommandParserError.optionNotAllowedHere(command: command, option: argValue) }
      arg.value = argValue
      tokens.remove(at: 0)
    }
    return (command, tokens)
  }
  
  private func parseSubCommand(_ c : CommandWithSubCommands, _ tkns : [String]) throws -> (command: Command, remainingTokens : [String]) {
    var command = c
    var tokens = tkns
    var subcommand = try command.getSubCommand(name: tokens[0])
    (subcommand, tokens) = try parseCommand(subcommand, tokens: tokens)
    command.subcommands.usedSubcommand = subcommand
    return (command, tokens)
  }
  
  
  // MARK: Token logic
  
  func isLongformOption(_ string : String) -> Bool {
    guard string.count >= 3 else { return false }
    return string.character(atIndex: 0) == "-"
      && string.character(atIndex: 1) == "-"
  }
  
  func getOptionName(_ string : String) -> String {
    return string.components(separatedBy: "=").first!
  }
  
  
  // MARK: Usage text & debug
  
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
