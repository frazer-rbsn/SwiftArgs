//
//  Command.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 30/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

enum CommandError : Error {
  case noSuchSubCommand(command:Command, subcommandName:String),
  noSuchOption(command:Command, optionName:String),
  optionRequiresArgument(command:Command, option:Option)
}

/**
 Encapsulates a command sent to your program.
 */
public protocol Command {
  
  /**
   Used for running the command.
   Must not contain spaces.
   */
  var name : String { get }
}


/**
 A standard bare-bones command model.
 */
public struct BasicCommand : Command {
  
  public let name : String
  
  public init(name : String) {
    self.name = name
  }
}


public protocol RunnableCommand : Command {
  
  /**
   Make the command grow legs and begin a light jog.
   Or whatever you want it to do.
   */
  func run()
}


/**
 A command that has optional parameters. Options allow users to alter the operation of a command.
 
 For example:
 ````
 makesquare --roundedcorners
 ````
 where `roundedcorners` is the name of the option.
 
 One or more options can with the command, in any order, as long as they are placed 
 BEFORE any of the command's required arguments in the command-line, if it has any.
 */
public protocol CommandWithOptions : Command {
  
  /**
   The options that can be used when running the command.
   Order does not matter here.
   Must not be empty.
   */
  var options : OptionArray { get set }
}


public struct OptionArray {
  
  var options : [OptionUsed] = []
  
  public init(_ options : Option...) {
    for o in options {
      let x = OptionUsed(o)
      self.options.append(x)
    }
  }
  
//  subscript(index: Int) -> OptionUsed {
//    get {
//      return options[index]
//    }
//  }
}


struct OptionUsed {
  
  var option : Option
  var used : Bool = false
  
  init(_ option: Option) {
    self.option = option
  }
}


public extension CommandWithOptions {
  
  public var optionNames : [String] {
    return options.options.map() { $0.option.name }
  }
  
  /**
   Option names with the "--" prefix.
   */
  public var optionLongForms : [String] {
    return options.options.map() { "--" + $0.option.name }
  }
  
  /**
   Options that were used with the command at runtime.
   */
  public var usedOptions : [Option] {
    return options.options.filter( { $0.used == true }).map() { $0.option }
  }
  
  func getOption(_ longFormName : String) throws -> Option {
    guard let i = optionLongForms.index(of: longFormName)
      else { throw CommandError.noSuchOption(command:self, optionName: longFormName) }
    return options.options[i].option
  }
  
  private func getOptionIndex(_ longFormName : String) throws -> Int {
    guard let i = optionLongForms.index(of: longFormName)
      else { throw CommandError.noSuchOption(command:self, optionName: longFormName) }
    return i
  }
  
  mutating func setOption(_ longFormName : String, value : String? = nil) throws {
    let op = try getOption(longFormName)
    if var owa = op as? OptionWithArgument {
      guard let v = value else { throw CommandError.optionRequiresArgument(command:self, option: owa) }
      owa.value = v
    }
    options.options[try getOptionIndex(longFormName)].used = true
  }
}


/**
 A command that has required positional arguments.
 
 For example:
 ````
 makeimage <width> <height>
 ````
 Where `width` and `height` are the arguments. This command would be used as follows:
 ````
 makeimage 200 300
 ````
 Arguments are positional, so set `arguments` with the desired order.
 */
public protocol CommandWithArguments : Command {
  
  /**
   Arguments are positional, so set them in the desired order.
   Must not be empty.
   */
  var arguments : [Argument] { get }
}

public extension CommandWithArguments {
  
  public var argumentNames : [String] {
    return arguments.map() { $0.name }
  }
  
  var allArgumentsSet : Bool {
    let flags = arguments.map() { $0.value != nil }
    return !flags.contains(where: { $0 == false })
  }
}


/**
 So I heard you like commands...
 
 In the command-line, subcommands can be used after a command. The subcommand must come AFTER any required arguments
 the command has.
 
 Subcommands are themselves Commands and the command logic is recursive, i.e. subcommands
 are processed in the same way as commands. They too can have options and required arguments.
 Chaining commands like this can be useful for more complex operations, or reusable command models.
 
 For example, you could have a Command model called "NewCommand" with the name "new". You could
 reuse this command as a subcommand, e.g:-
 ````
 file new
 project new
 ````
 Where `file` and `project` are commands, and your `new` command is a subcommand for both.
 */
public protocol CommandWithSubCommands : Command {
  
  /**
   This property says which subcommands the user can use on this command. The user can only pick one,
   or none at all.
   The subcommand that was used at runtime, if any, is set in `usedSubcommand`.
   */
  var subcommands : SubcommandArray { get set }
}

public struct SubcommandArray {
  
  var commands : [Command] = []
  var usedSubcommand : Command?
  
  var isEmpty : Bool {
    return commands.isEmpty
  }
  
  public init(_ commands : Command...) {
    self.commands = commands
  }
  
  subscript(index: Int) -> Command {
    get {
      return commands[index]
    }
  }
}

public extension CommandWithSubCommands {
  
  public var usedSubcommand : Command? {
    return subcommands.usedSubcommand
  }
  
  func getSubCommand(name : String) throws -> Command {
    guard let c = subcommands.commands.filter({ $0.name == name }).first
      else { throw CommandError.noSuchSubCommand(command: self, subcommandName: name) }
    return c
  }
}


public func ==(l: Command, r: Command) -> Bool {
  return l.name == r.name
}


/**
 Has text that can be printed as part of usage information.
 */
public protocol HasHelpText {
  
  /**
   Usage information for users.
   */
  var helpText : String { get }
}
