//

import Foundation

// MARK: - Builder Models

public struct Command : Hashable {
  let name : CommandName
  let arguments : [Argument]
  let options : [Option]
}

struct Argument : Hashable {
  let name : ArgumentName
}

struct Option : Hashable {
  let name : OptionName
  let arguments : [Argument]
  
  var token : String {
    return "--" + name.rawValue
  }
}

// MARK: - Parsed Models

public final class ParsedCommand {
  
  public let name : CommandName
  internal(set) public var arguments : [ArgumentName:ParsedArgument] = [:]
  internal(set) public var options : [OptionName:ParsedOption] = [:]
  
  public init(name : CommandName) {
    self.name = name
  }
}

public final class ParsedArgument {
  
  public let name : ArgumentName
  public let value : String
  
  public init(name : ArgumentName, value : String) {
    self.name = name
    self.value = value
  }
}

public final class ParsedOption {
  
  public let name : OptionName
  internal(set) public var arguments : [ArgumentName:ParsedArgument] = [:]
  
  public init(name : OptionName) {
    self.name = name
  }
}

// MARK: - Name structs

public struct CommandName : Hashable, Equatable, RawRepresentable {

  public typealias RawValue = String
  
  public let rawValue: CommandName.RawValue
  
  public init(rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
  
  public init(_ rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
}

public struct ArgumentName : Hashable, Equatable, RawRepresentable {

  public typealias RawValue = String
  
  public let rawValue: CommandName.RawValue
  
  public init(rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
  
  public init(_ rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
}

public struct OptionName : Hashable, Equatable, RawRepresentable {

  public typealias RawValue = String
  
  public let rawValue: CommandName.RawValue
  
  public init(rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
  
  public init(_ rawValue: CommandName.RawValue) {
    self.rawValue = rawValue
  }
}
