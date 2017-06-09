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
   You should set this to nil in your Argument model.
   */
  var value : String? { get set }
}


/**
 A standard, bare-bones Argument object.
 */
public struct BasicArgument : Argument {
  
  public let name : String
  public var value : String?
  
  public init(_ name : String) {
    self.name = name
  }
}
