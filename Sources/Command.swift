//
//  Command.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 30/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

import Foundation

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
    var helptext : String { get set }
    
    /**
     The required arguments to be used when running the command.
     Set these arguments in the order that you require them in.
     */
    var arguments : [Argument] { get set }
    
    /**
     The options that can be used when running the command. Order does not matter here.
     */
    var options : [Option] { get set }
    
    /**
     Make the command grow legs and begin a light jog.
     */
    func run()
}

public enum CommandError : Error {
    case noOptions(String),
        noSuchOption(String),
        optionRequiresArgument(String),
        requiresArguments(String),
        noArguments(String),
        invalidArguments(commandName : String, suppliedArguments : [String])
}


public extension Command {
    
    public var hasOptions : Bool {
        return !options.isEmpty
    }

    public var optionNames : [String] {
        return options.map() { $0.name }
    }
    
    public var optionLongForms : [String] {
        return options.map() { "--" + $0.name }
    }
    
    public var hasRequiredArguments : Bool {
        return !arguments.isEmpty
    }

    public var argumentNames : [String] {
        return arguments.map() { $0.name }
    }
    
    /**
     Returns an `Option` object that belongs to the command.
     
     - parameter name: The "name" property of the option
     
     - returns: a `Option` object if the option exists and
                is a member of the Command's `options` property,
                or nil if no option with `name` is found.
     */
    public func getOption(_ name : String) -> Option? {
        return options.filter() { $0.name == name }.first
    }
    
    /**
     Sets the option on the command. Use for setting flags/switches.
     
     - parameter name: The "name" property of the option
     
     - throws:  `CommandOptionError.NoSuchOption` if no option with `name` is found,
                or the option has not been set, or nil if it is does not conform to
                the `VariableOption` protocol.
     */
    public mutating func setOption(_ o : String) throws {
        try setOption(o, value: nil)
    }
    
    /**
     Sets the option on the command. Use this function for options that
     require an argument.
     
     - parameter name: The `name` property of the option.
     - parameter value: The argument value to use with the option.
     
     - throws:  `CommandOptionError.noSuchOption` if no option with `name` is found,
                or `CommandOptionError.optionRequiresArgument` if option conforms to
                `OptionWithArgument` protocol and `value` is nil.
     */
    public mutating func setOption(_ o : String, value : String?) throws {
        guard let i = optionLongForms.index(of: o) else { throw CommandError.noSuchOption(o) }
        if var op = options[i] as? OptionWithArgument {
            guard let v = value else { throw CommandError.optionRequiresArgument(op.name) }
            op.value = v
        }
        options[i].set = true
    }
    
}

public func ==(lhs: Command, rhs: Command) -> Bool {
    return lhs.name == rhs.name
}

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

public func ==(lhs: Option, rhs: Option) -> Bool {
    return lhs.name == rhs.name
}

/**
 For options that would be used as,  YourProgramName yourcommandname --youroptionname=<arg>
 For example, AwesomeScript make --directory=/mydir/mysubdir/
 */
public protocol OptionWithArgument : Option {
    
    /**
     Used when printing usage info.
     */
    var argumentName : String { get }
    
    /**
     The value of the option's argument when set at command runtime.
     If the `set` property is not true, this value will not be used.
     */
    var value : String? { get set }
}

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

public func ==(lhs: Argument, rhs: Argument) -> Bool {
    return lhs.name == rhs.name
}
