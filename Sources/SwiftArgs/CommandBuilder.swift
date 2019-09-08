//

import Foundation

public final class CommandBuilder {
  
  private let name : String
  private var arguments : [Argument] = []
  private var options : [Option] = []
  
  public init(name : String) {
    self.name = name
  }
  
  public func withArgument(name : String) -> Self {
    arguments.append(Argument(name: name))
    return self
  }
  
  public func withOption(name : String, arguments : [String]) -> Self {
    let arguments = arguments.map(Argument.init)
    options.append(Option(name: name, arguments: arguments))
    return self
  }
  
  public func build() -> Command {
    return Command(name: name, arguments: arguments, options: options)
  }
}
