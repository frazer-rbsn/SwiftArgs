//
//  Command.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 30/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//

internal enum CommandError : Error {
    case noSuchSubCommand(command:Command, subCommandName:String),
    noSuchOption(command:Command, optionName:String),
    optionRequiresArgument(command:Command, option:Option)
}


/**
 Encapsulates a command sent to your program.
 To make a standard bare-bones command model, conform to this protocol.
 */
public protocol Command {
    
    /**
     Used for running the command.
     Must not contain spaces.
     */
    static var name : String { get }
    
    /**
     Usage information for end users.
     */
    var helptext : String { get }
    
    init()
}

protocol RunnableCommand : Command {
    
    /**
     Make the command grow legs and begin a light jog.
     Or whatever you want it to do.
     */
    func run()
}

/**
 Options allow users to alter the operation of a command.
 
 For example:
 ````
 makesquare --roundedcorners
 ````
 where `roundedcorners` is the name of the option.
 
 One or more options can with the command, in any order, as long as they are placed 
 BEFORE any of the command's required arguments in the command line, if it has any.
 */
public protocol CommandWithOptions : Command {
    
    /**
     The options that can be used when running the command.
     Order does not matter here.
     Must not be empty.
     */
    var options : [Option] { get set }
}

extension CommandWithOptions {
    
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
}

/**
 Commands that have required arguments.
 
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
    var arguments : [Argument] { get set }
}

extension CommandWithArguments {

    internal var argumentNames : [String] {
        return arguments.map() { $0.name }
    }
    
    internal var allArgumentsSet : Bool {
        let flags = arguments.map() { $0.value != nil }
        return !flags.contains(where: { $0 == false })
    }
}


/**
 So I heard you like commands...
 
 In the command line, subcommands can be used after a command. The subcommand must come AFTER any required arguments
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
        guard let c = subCommands.filter({ type(of:$0).name == name }).first
            else { throw CommandError.noSuchSubCommand(command: self, subCommandName: name) }
        return c
    }
}

public func ==(l: Command.Type, r: Command.Type) -> Bool {
    return l.name == r.name
}
