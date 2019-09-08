//

import Foundation

// MARK: - Builder Models

public struct Command : Hashable {
  let name : String
  let arguments : [Argument]
  let options : [Option]
}

struct Argument : Hashable {
  let name : String
}

struct Option : Hashable {
  let name : String
  let arguments : [Argument]
  
  var token : String {
    return "--" + name
  }
}

// MARK: - Parsed Models

public final class ParsedCommand {
  public let name : String
  internal(set) public var arguments : [ParsedArgument] = []
  internal(set) public var options : [ParsedOption] = []
  
  public init(name : String) {
    self.name = name
  }
}

public final class ParsedArgument {
  public let name : String
  public let value : String
  
  public init(name : String, value : String) {
    self.name = name
    self.value = value
  }
}

public final class ParsedOption {
  public let name : String
  internal(set) public var arguments : [ParsedArgument] = []
  
  public init(name : String) {
    self.name = name
  }
}
