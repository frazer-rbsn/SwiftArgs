//
//  Command.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 30/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

public enum CommandError : Error {
    case noSuchSubCommand(command:Command, subCommandName:String),
    noSuchOption(command:Command, optionName:String),
    optionRequiresArgument(command:Command, option:Option)
}


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
    public var usedOptions : [Option] {
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
}

protocol RunnableCommand : Command {
    
    /**
     Make the command grow legs and begin a light jog.
     Or whatever you want it to do.
     */
    func run()

}

/**
 So I heard you like commands...
 In the command line, subcommands can be used after a command. The subcommand must come AFTER any required arguments
 the command has.
 
 Subcommands are themselves Commands and the command logic is recursive, i.e. subcommands
 are processed in the same way as commands. They too can have options and required arguments.
 */
protocol CommandWithSubCommands : Command {
    

    /**
     This property says which subcommands the user can use on this command. The user can only pick one,
     or none at all.
     The subcommand that was used at runtime, if any, is set in `usedSubCommand`.
    */
    var subCommands : [Command] { get set }
    
    /**
     If a subcommand was sent to the parser with this command, it will be stored in this property.
     */
    var usedSubCommand : Command? { get set }
    
}

extension CommandWithSubCommands {
    
    internal func getSubCommand(name : String) throws -> Command {
        guard let c = subCommands.filter({ $0.name == name }).first
            else { throw CommandError.noSuchSubCommand(command: self, subCommandName: name) }
        return c
    }
}

public func ==(lhs: Command, rhs: Command) -> Bool {
    return lhs.name == rhs.name
}
