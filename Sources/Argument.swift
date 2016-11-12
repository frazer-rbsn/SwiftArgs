//
//  Argument.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 12/11/2016.
//
//

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
