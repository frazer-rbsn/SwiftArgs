//
//  Command.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 30/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

import Foundation


// MARK: Command

/**
 Encapsulates a command sent to your Swift program.
 To make a command model, conform to this protocol.
 */
public protocol Command {
    
    /**
     Used for running the command.
     Must not contain spaces.
     */
    var name : String { get }
    
    /**
     Usage information for end users.
     */
    var helptext : String { get }
    
    /**
     The options that can be used when running the command. Order does not matter here.
     Options are not required. Options are used BEFORE any of the command's
     required arguments in the command line, if it has any.
     */
    var options : [Option] { get set }
    
    /**
     The required arguments to be used when running the command.
     Set these arguments in the order that you require them in.
     Arguments come AFTER any options in the command line.
     */
    var arguments : [Argument] { get set }
    
    /**
     So I heard you like commands...
     In the command line, subcommands can be used after a command. The subcommand must come AFTER any required arguments
     the command has.
     
     Subcommands are themselves Commands and the command logic is recursive, i.e. subcommands 
     are processed in the same way as commands. They too can have options and required arguments.
     
     This property says which subcommands the user can use on this command. The user can only pick one,
     or none at all.
     The subcommand that is used at runtime is set in `usedSubCommand`.
     */
    var subCommands : [Command] { get set }
    
    /**
     If a subcommand was sent to the parser with this command, it will be stored in this property.
    */
    var usedSubCommand : Command? { get set }
    
    /**
     Make the command grow legs and begin a light jog.
     Or whatever you want it to do.
     */
    func run()
}

public enum CommandError : Error {
    case noSuchSubCommand(command:Command, subCommandName:String),
        noSuchOption(command:Command, optionName:String),
        optionRequiresArgument(command:Command, option:Option)
}


extension Command {

    public var optionNames : [String] {
        return options.map() { $0.name }
    }
    
    /**
     Option names with the "--" prefix.
    */
    public var optionLongForms : [String] {
        return options.map() { "--" + $0.name }
    }
    
    /**
     Options that were used with the command at runtime.
    */
    public var setOptions : [Option] {
        return options.filter( { $0.set == true })
    }
    
    internal var hasOptions : Bool {
        return !options.isEmpty
    }
    
    internal func getOption(_ name : String) throws -> Option {
        guard let option = options.filter({ $0.name == name }).first
            else { throw CommandError.noSuchOption(command:self, optionName: name) }
        return option
    }
    
    internal mutating func setOption(_ o : String) throws {
        try setOption(o, value: nil)
    }
    
    internal mutating func setOption(_ o : String, value : String?) throws {
        guard let i = optionLongForms.index(of: o)
            else { throw CommandError.noSuchOption(command:self, optionName: o) }
        if var op = options[i] as? OptionWithArgument {
            guard let v = value else { throw CommandError.optionRequiresArgument(command:self, option: op) }
            op.value = v
        }
        options[i].set = true
    }
    
    internal var hasRequiredArguments : Bool {
        return !arguments.isEmpty
    }

    internal var argumentNames : [String] {
        return arguments.map() { $0.name }
    }
    
    internal var allArgumentsSet : Bool {
        let flags = arguments.map() { $0.value != nil }
        return !flags.contains(where: { $0 == false })
    }
    
    internal var hasSubCommands : Bool {
        return !subCommands.isEmpty
    }
    
    internal func getSubCommand(name : String) throws -> Command {
        guard let c = subCommands.filter({ $0.name == name }).first
            else { throw CommandError.noSuchSubCommand(command: self, subCommandName: name) }
        return c
    }
    
}

public func ==(lhs: Command, rhs: Command) -> Bool {
    return lhs.name == rhs.name
}


// MARK: Option

/**
 Arguments that are optional when running the command.
 Come after the command name and before any required arguments.
 To make an option model, conform to this protocol.
 */
public protocol Option {
    
    /**
     Used for specifying the option in short form when running the associated command,
     and the option's name in the usage information.
     Must not contain spaces. 
     Do not include dashes, these will be added for you.
     */
    //var shortName : Character { get }
    
    /**
     Used for specifying the option in long form when running the associated command,
     and the option's name in the usage information.
     Must not contain spaces.
     Do not include dashes, these will be added for you.
     
     Must be unique for the command.
     */
    var name : String { get }
    
    /**
     Will be set to true if the option was specified when the command was run.
     In your Option model, in normal cases you should set this value to false.
     If you want though, you could set it to true to always have this option added
     regardless of user input.
     */
    var set : Bool { get set }
}

public extension Option {
    
//    var shortFormName : Character {
//        return "-\(shortName)"
//    }
    
    var longFormName : String {
        return "--\(name)"
    }
    
}

/**
 For options that would be used as,  yourcommandname --youroptionname=<arg>
 For example, make --directory=/mydir/mysubdir/
 */
public protocol OptionWithArgument : Option {
    
    /**
     Used when printing usage info.
     */
    var argumentName : String { get }
    
    /**
     The value of the option's argument when set at command runtime.
     */
    var value : String? { get set }
}


// MARK: Argument

/**
 A required argument when running the associated command. 
 Must come after any options when running the command.
 To make an argument model, conform to this protocol.
 */
public protocol Argument {
    
    /**
     Printed in usage information.
     
     Must be unique for the command.
     */
    var name : String { get }
    
    /**
     The value of the argument at command runtime.
     Normally, you should set this to nil in your Argument model.
     However you can also set it to a default value that will be used if the user
     does not supply the argument.
     */
    var value : String? { get set }
}

