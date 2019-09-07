//
//  CommandRegister.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 11/06/2017.
//

import Foundation

final class CommandRegister : HasDebugMode {
  
  private var commands : [Command] = []
  
  var debugMode = false
  var isEmpty : Bool { return commands.isEmpty }
  var count : Int { return commands.count }
  
  func getCommand(_ name : String) throws -> Command {
    guard let c = commands.filter({ $0.name == name }).first else { throw CommandParserError.noSuchCommand(name) }
    return c
  }
  
  func printCommands() {
    UsageInfoPrinter().printCommands(commands)
  }
  
  func insert(_ command : Command) throws {
    guard !commands.contains(where: { $0 == command }) else {
      printDebug("Error: Duplicate command model \'\(command)\'.")
      printDebug("CommandParser already has a registered command with name: \'\(command.name)\'")
      throw CommandParserError.duplicateCommand
    }
    try CommandValidator(debugMode: debugMode).validate(command)
    commands.append(command)
  }
  
  func insert(_ commandNames : [String]) throws {
    for n in commandNames {
      let command = BasicCommand(name: n)
      try insert(command)
    }
  }
  
  func has(_ command : Command) -> Bool {
    return commands.contains(where: { $0 == command })
  }
}
