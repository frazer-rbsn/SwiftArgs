//
//  UsageInfoPrinter.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 01/11/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public final class UsageInfoPrinter {
  
  public func printCommands(_ cmds : [Command]) {
    guard !cmds.isEmpty else { return } // No registered commands
    print("\nCOMMANDS:")
    _printNameAndHelpText(for: cmds)
    print()
  }
  
  public func printHelpAndUsage(for command : Command) {
    print("\nCOMMAND:")
    _printNameAndHelpText(for: command)
    print("\nUSAGE:")
    _printCommandUsage(command)
    print("\n")
  }
  
  public func printUsage(for command : Command) {
    print("\nUSAGE:")
    _printCommandUsage(command)
    print("\n")
  }
  
  private func _printNameAndHelpText(for cmds : [Command]) {
    for c in cmds {
      _printNameAndHelpText(for: c)
      print()
    }
  }
  
  private func _printNameAndHelpText(for cmd: Command) {
    print("    \(cmd.name)", terminator: "")
    if let c = cmd as? HasHelpText {
      print("    \(c.helpText)")
    }
  }
  
  private func _printCommandUsage(_ cmd : Command) {
    print("    \(cmd.name)", terminator:" ")
    if let c = cmd as? CommandWithOptions {
      for o in c.options.options {
        print("[\(o.option.longFormName)", terminator:"] ")
      }
    }
    if let c = cmd as? CommandWithArguments {
      for a in c.arguments {
        print("<\(a.name)>", terminator: " ")
      }
    }
    if let c = cmd as? CommandWithSubCommands { //TODO:
      print("\n\nSUBCOMMANDS:")
      for subcommand in c.subcommands.commands {
        _printNameAndHelpText(for: subcommand)
      }
    }
  }
  
  private func _printCommandElementInfo(_ cmd : Command) {
    if let c = cmd as? CommandWithOptions {
      print("\n\nOPTIONS:")
      for o in c.options.options {
        print("\(o.option.longFormName)", terminator: "")
        if let oht = o as? HasHelpText {
          print("    \(oht.helpText)")
        } else { print() }
      }
    }
    if let c = cmd as? CommandWithArguments {
      print("\n\nARGUMENTS:")
      for a in c.arguments {
        print("\(a.name)", terminator: "")
        if let aht = a as? HasHelpText {
          print("    \(aht.helpText)")
        } else { print() }
      }
    }
    if let c = cmd as? CommandWithSubCommands {
      print("\n\nSUBCOMMANDS:")
      for s in c.subcommands.commands {
        print("    \(s.name)", terminator: "")
        if let sht = s as? HasHelpText {
          print("    \(sht.helpText)")
        } else { print() }
      }
    }
  }
}
