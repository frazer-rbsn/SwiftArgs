//
//  Option.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 12/11/2016.
//
//

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
