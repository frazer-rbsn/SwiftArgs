//

import Foundation

public final class CommandRegistrar {
  
  enum Error : LocalizedError {
    case duplicateCommandName(String)
  }
  
  private var commands = Set<Command>()
  
  public func register(command : Command) throws {
    guard !commands.contains(where: { $0.name == command.name }) else {
      throw Error.duplicateCommandName(command.name)
    }
    commands.insert(command)
  }
  
  public func register(commands : [Command]) throws {
    for c in commands {
     try register(command: c)
    }
  }
  
  func command(name : String) -> Command? {
    return commands.first(where: { $0.name == name})
  }
}
