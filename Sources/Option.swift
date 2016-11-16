//
//  Option.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 12/11/2016.
//
//

/**
 Arguments that are optional when running the command.
 They are positioned after the command name and before any required arguments.
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
     Will be set to `true` if the option was specified when the command was run.
     */
    var set : Bool { get set }
    
    init()
}

public extension Option {
    
    //    var shortFormName : Character {
    //        return "-\(shortName)"
    //    }
    
    /**
     The option name with the "--" prefix.
     */
    var longFormName : String {
        return "--\(name)"
    }
    
}

/**
 Options that require a value to be passed to them when used.
 Used as, for example:
 ````
 yourcommandname --youroptionname=<arg>
 ````
 ````
 make --directory=/mydir/mysubdir/
 ````
 */
public protocol OptionWithArgument : Option {
    
    /**
     Used when printing usage info.
     Must not contain spaces.
     Must be unique for the command.
     */
    var argumentName : String { get }
    
    /**
     The value of the option's argument when set at command runtime.
     */
    var value : String? { get set }
}
