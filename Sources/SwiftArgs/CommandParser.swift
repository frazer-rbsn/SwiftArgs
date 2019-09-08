//

import Foundation

public final class CommandParser {
  
  private typealias Token = String
  
  private let registrar : CommandRegistrar
  private let delegate : CommandParserDelegate
  
  public init(registrar : CommandRegistrar, delegate : CommandParserDelegate) {
    self.registrar = registrar
    self.delegate = delegate
  }
  
  public convenience init(commands : [Command], delegate : CommandParserDelegate) throws {
    let registrar = CommandRegistrar()
    try registrar.register(commands: commands)
    self.init(registrar: registrar, delegate: delegate)
  }
  
  public func parse(input : String) {
    var tokens = input.split(separator: " ").map(String.init)
    guard tokens.count > 0 else {
      delegate.noCommandsPassed()
      return
    }
    let commandName = String(tokens.removeFirst())
    if let command = registrar.command(name: commandName) {
      parse(command: command, tokens: tokens)
    } else {
      delegate.parserError(error: Error.unknownCommand(commandName))
    }
  }
  
  private func parse(command : Command, tokens : [Token]) {
    var parsedCommand = ParsedCommand(name: command.name)
    parse(command: command, parsedCommand: &parsedCommand, tokens: tokens)
  }
  
  private func parse(command : Command, parsedCommand : inout ParsedCommand, tokens : [Token]) {
    var tokens = tokens
    if let (option, remainingTokens) = parseOption(command: command, tokens: tokens) {
      parsedCommand.options.append(option)
      return parse(command: command, parsedCommand: &parsedCommand, tokens: remainingTokens)
    }
    do {
      (parsedCommand.arguments, tokens) = try parseArguments(arguments: command.arguments, tokens: tokens)
    } catch {
      delegate.parserError(error: error)
    }
    guard tokens.isEmpty else {
      delegate.parserError(error: Error.unexpectedParameters(tokens))
      return
    }
    delegate.didParseCommand(parsedCommand)
  }
  
  private func parseOption(command : Command, tokens : [Token]) -> (ParsedOption, [Token])? {
    var tokens = tokens
    let optionNameToken = tokens.removeFirst()
    guard optionNameToken.hasPrefix("--") else {
      return nil
    }
    if let option = command.options.first(where: { $0.token == optionNameToken }) {
      let parsedOption = ParsedOption(name: option.name)
      do {
        (parsedOption.arguments, tokens) = try parseArguments(arguments: option.arguments, tokens: tokens)
        return (parsedOption, tokens)
      } catch {
        delegate.parserError(error: error)
      }
    } else {
      delegate.parserError(error: Error.unknownOption(optionNameToken))
    }
    return nil
  }
  
  private func parseArguments(arguments : [Argument], tokens : [Token]) throws -> ([ParsedArgument], [Token]) {
    var tokens = tokens
    var parsedArguments = [ParsedArgument]()
    for argument in arguments {
      guard !tokens.isEmpty else {
        throw Error.expectedArgument(argument.name)
      }
      let argumentToken = tokens.removeFirst()
      let parsedArgument = parseArgument(argument: argument, token: argumentToken)
      parsedArguments.append(parsedArgument)
    }
    return (parsedArguments, tokens)
  }
  
  private func parseArgument(argument : Argument, token : Token) -> ParsedArgument {
    return ParsedArgument(name: argument.name, value: token)
  }
}

public protocol CommandParserDelegate {
  func didParseCommand(_ parsedCommand : ParsedCommand)
  func noCommandsPassed()
  func parserError(error: Error)
}

extension CommandParser {
  
  enum Error : LocalizedError {
    case unexpectedParameters([String])
    case expectedArgument(String)
    case unknownCommand(String)
    case unknownOption(String)
  }
}
