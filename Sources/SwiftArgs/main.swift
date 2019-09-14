//

import Foundation

extension CommandName {
  static let foo = CommandName("foo")
}

extension ArgumentName {
  static let bar = ArgumentName("bar")
}

extension OptionName {
  static let baz = OptionName("baz")
}

let command = CommandBuilder(name: .foo)
  .withArgument(name: .bar)
  .withOption(name: .baz, arguments: [])
  .build()
