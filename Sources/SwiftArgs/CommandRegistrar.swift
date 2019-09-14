//

import Foundation

public final class CommandRegistrar {
  
  private var commands = Set<Command>()
  
  var hasCommands : Bool {
    return !commands.isEmpty
  }
  
  public func register(command : Command) throws {
    guard !commands.contains(where: { $0.name == command.name }) else {
      throw Error.duplicateCommandName(command.name.rawValue)
    }
    commands.insert(command)
  }
  
  public func register(commands : [Command]) throws {
    for c in commands {
     try register(command: c)
    }
  }
  
  func command(name : String) -> Command? {
    return commands.first(where: { $0.name == CommandName(name) })
  }
}

extension CommandRegistrar {
  
  enum Error : LocalizedError {
    case duplicateCommandName(String)
  }
}
