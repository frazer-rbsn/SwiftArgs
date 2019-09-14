//

import Foundation

public final class CommandBuilder {
  
  private let name : CommandName
  private var arguments : [Argument] = []
  private var options : [Option] = []
  
  public init(name : CommandName) {
    self.name = name
  }
  
  public func withArgument(name : ArgumentName) -> Self {
    arguments.append(Argument(name: name))
    return self
  }
  
  public func withOption(name : OptionName, arguments : [ArgumentName]) -> Self {
    let arguments = arguments.map(Argument.init)
    options.append(Option(name: name, arguments: arguments))
    return self
  }
  
  public func build() -> Command {
    return Command(name: name, arguments: arguments, options: options)
  }
}
