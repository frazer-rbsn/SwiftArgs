//

import Foundation

public protocol CommandParserDelegate {
  func didParseCommand(_ parsedCommand : ParsedCommand)
  func noCommandsPassed()
  func parserError(error: LocalizedError)
}

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
    guard tokens.count > 0 else { fatalError() }
    let commandName = String(tokens.removeFirst())
    if let command = registrar.command(name: commandName) {
      parse(command: command, tokens: tokens)
    }
  }
  
  private func parse(command : Command, tokens : [Token]) {
    var parsedCommand = ParsedCommand(name: command.name)
    parse(command: command, parsedCommand: &parsedCommand, tokens: tokens)
    delegate.didParseCommand(parsedCommand)
  }
  
  private func parse(command : Command, parsedCommand : inout ParsedCommand, tokens : [Token]) {
    var tokens = tokens
    if let (option, remainingTokens) = parseOption(command: command, tokens: tokens) {
      parsedCommand.options.append(option)
      return parse(command: command, parsedCommand: &parsedCommand, tokens: remainingTokens)
    }
    (parsedCommand.arguments, tokens) = parseArguments(arguments: command.arguments, tokens: tokens)
    guard tokens.isEmpty else {
      fatalError()
    }
  }
  
  private func parseOption(command : Command, tokens : [Token]) -> (ParsedOption, [Token])? {
    var tokens = tokens
    let optionNameToken = tokens.removeFirst()
    if let option = command.options.first(where: { $0.token == optionNameToken }) {
      let parsedOption = ParsedOption(name: option.name)
      (parsedOption.arguments, tokens) = parseArguments(arguments: option.arguments, tokens: tokens)
      return (parsedOption, tokens)
    }
    return nil
  }
  
  private func parseArguments(arguments : [Argument], tokens : [Token]) -> ([ParsedArgument], [Token]) {
    var tokens = tokens
    var parsedArguments = [ParsedArgument]()
    for argument in arguments {
      guard !tokens.isEmpty else {
        fatalError()
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
