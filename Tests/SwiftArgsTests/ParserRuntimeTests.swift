import XCTest
@testable import SwiftArgs

final class ParserRuntimeTests : XCTestCase {
  
  // MARK: - Valid scenarios
  
  func testParseNoCommands() {
    let parser = CommandParser()
    try! parser.register(MockCommand())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: [], delegate: delegate)
    XCTAssert(delegate.commandNotSuppliedFlag)
  }
  
  func testParseBlankCommand() {
    let parser = CommandParser()
    try! parser.register(MockCommand())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: [""], delegate: delegate)
    XCTAssert(delegate.commandNotSuppliedFlag)
  }
  
  func testParseValidCommandOptionNotSet() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOption())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssertFalse(c.options[0].used)
    XCTAssert(c.usedOptions.count == 0)
  }
  
  func testParseValidCommandWithOptionWithArgument() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOptionWithArgument())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg=arg"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "arg")
    XCTAssert(c.usedOptions.count == 1)
  }
  
  func testParseValidCommandWithOptionWithArgumentStartsWithHypen() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOptionWithArgument())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg=-arg"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "-arg")
    XCTAssert(c.usedOptions.count == 1)
  }
  
  func testParseValidCommandWithOptionWithArgumentNoEqualsSign() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOptionWithArgument())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg", "arg"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "arg")
    XCTAssert(c.usedOptions.count == 1)
  }
  
  func testParseValidCommandWithOptionWithArgumentNoEqualsSignArgStartsWithHyphen() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOptionWithArgument())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg", "-arg"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "-arg")
    XCTAssert(c.usedOptions.count == 1)
  }
  
  func testParseValidCommandWithOptionWithArgumentEmptyArg() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOptionWithArgument())
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg="], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "")
    XCTAssert(c.usedOptions.count == 1)
  }
  
  func testParseValidCommandWithTwoOptions() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOption(name:"op1"), MockOption(name:"op2"))
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--op1", "--op2"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert(c.options[1].used)
    XCTAssert(c.usedOptions.count == 2)
  }
  
  func testParseValidCommandWithTwoArgs() {
    class C : MockCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg1value", "arg2value"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithArguments
    XCTAssertEqual(c.arguments[0].value!, "arg1value")
    XCTAssertEqual(c.arguments[1].value!, "arg2value")
    XCTAssert(c.allArgumentsSet)
  }
  
  func testParseValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
    class C : MockCommand, CommandWithOptions, CommandWithArguments {
      var options = OptionArray(MockOption(), MockOptionWithArgument())
      var arguments : [Argument] = [MockArgument()]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoption", "--mockoptionwitharg=value", "argumentvalue"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert(c.options[1].used)
    XCTAssert((c.options[1].option as! OptionWithArgument).value! == "value")
    XCTAssertEqual((delegate.command as! CommandWithArguments).arguments[0].value!, "argumentvalue")
  }
  
  func testParseValidCommandWithSubcommandWithArgument() {
    class SubCMD : MockSubCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument()]
    }
    class C : MockCommand, CommandWithSubCommands {
      var subcommands = SubcommandArray(SubCMD())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "mocksubcommand", "subcommandargvalue"], delegate: delegate)
    let command = delegate.command! as! CommandWithSubCommands
    XCTAssert(command is C)
    XCTAssertNotNil(command.usedSubcommand)
    XCTAssert(command.usedSubcommand!.name == SubCMD.init().name)
    XCTAssert((command.usedSubcommand! as! CommandWithArguments).arguments[0].value! == "subcommandargvalue")
  }
  
  func testParseValidCommandWithArgumentWithSubcommand() {
    class C : MockCommand, CommandWithArguments, CommandWithSubCommands {
      var arguments : [Argument] = [MockArgument()]
      var subcommands = SubcommandArray(MockSubCommand())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "commandargvalue", "mocksubcommand"], delegate: delegate)
    let command = delegate.command! as! CommandWithSubCommands
    XCTAssert(command is C)
    XCTAssert((command as! CommandWithArguments).arguments[0].value! == "commandargvalue")
    XCTAssertNotNil(command.usedSubcommand)
    XCTAssert(command.usedSubcommand!.name == MockSubCommand.init().name)
  }
  
  func testParseValidCommandWithTwoArgumentsWithSubcommand() {
    class C : MockCommand, CommandWithArguments, CommandWithSubCommands {
      var arguments : [Argument] = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
      var subcommands = SubcommandArray(MockSubCommand())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg1value", "arg2value", "mocksubcommand"], delegate: delegate)
    let command = delegate.command! as! CommandWithSubCommands
    XCTAssert(command is C)
    XCTAssert((command as! CommandWithArguments).arguments[0].value! == "arg1value")
    XCTAssert((command as! CommandWithArguments).arguments[1].value! == "arg2value")
    XCTAssertNotNil(command.usedSubcommand)
    XCTAssert(command.usedSubcommand!.name == MockSubCommand.init().name)
  }
  
  func testParseValidCommandWithOneOptionWithArgAndSubcommand() {
    class C : MockCommand, CommandWithOptions, CommandWithSubCommands {
      var options = OptionArray(MockOptionWithArgument())
      var subcommands = SubcommandArray(MockSubCommand())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--mockoptionwitharg", "arg", "mocksubcommand"], delegate: delegate)
    XCTAssertNotNil(delegate.command)
    let c = delegate.command as! CommandWithOptions
    XCTAssert(c.options[0].used)
    XCTAssert((c.options[0].option as! OptionWithArgument).value! == "arg")
    let cs = delegate.command as! CommandWithSubCommands
    XCTAssertNotNil(cs.usedSubcommand)
    XCTAssert(cs.usedSubcommand!.name == MockSubCommand.init().name)
  }
  
  
  // MARK: - Invalid scenarios
  
  func testParseWithNoRegisteredCommandsThrows() {
    let parser = CommandParser()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["generate"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.noCommands {} else {
      XCTFail()
    }
  }
  
  func testParseNonExistingCommandThrows() {
    let nonExistantCommandName = "foo"
    let parser = CommandParser()
    try! parser.register(MockCommand())
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: [nonExistantCommandName], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.noSuchCommand(nonExistantCommandName) {} else {
      XCTFail()
    }
  }
  
  func testParseCommandWithNoSuchOptionThrows() {
    class C : MockCommand, CommandWithOptions {
      var options = OptionArray(MockOption(name:"foo"))
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let nonExistantOption = "--bar"
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: [cmd.name, nonExistantOption], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.noSuchOption(command: cmd, option: nonExistantOption) {} else {
      XCTFail()
    }
  }
  
  func testParseCommandWithOneOptionAsCommandThatHasNoOptionsThrows() {
    let parser = CommandParser()
    try! parser.register(MockCommand())
    let cmd = MockCommand.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--option"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.noOptions(cmd) {} else {
      XCTFail()
    }
  }
  
  func testParseCommandWithOptionThatRequiresArgumentNoArgThrows() {
    class C : MockCommand, CommandWithOptions {
      var op = MockOptionWithArgument(name:"op")
      var options : OptionArray
      required init() {
        options = OptionArray(op)
      }
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "--op"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.optionRequiresArgument(command: cmd, option: cmd.op) {} else {
      XCTFail()
    }
  }
  
  func testSendNoArgsWithCommandThatRequiresArgsThrows() {
    class C : MockCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument()]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.requiresArguments(cmd) {} else {
      XCTFail()
    }
  }
  
  func testSendOneArgWithCommandThatHasNoArgsNoSubCommandsThrows() {
    let parser = CommandParser()
    try! parser.register(MockCommand())
    let cmd = MockCommand.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.invalidArgumentOrSubCommand(cmd) {} else {
      XCTFail()
    }
  }
  
  func testSendOneArgWithCommandThatHasNoArgsNoSuchSubCommandThrows() {
    class C : MockCommand, CommandWithSubCommands {
      var subcommands = SubcommandArray(MockSubCommand())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "notmocksubcommand"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.noSuchSubCommand(command: cmd, subcommandName: "bar") {} else {
      XCTFail()
    }
  }
  
  func testSendOneArgWithCommandThatRequiresTwoArgsThrows() {
    class C : MockCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument(name:"arg1"), MockArgument(name:"arg2")]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg1"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.invalidArguments(cmd) {} else {
      XCTFail()
    }
  }
  
  func testSendOneArgOneOptionAfterArgWithCommandThatRequiresTwoArgsThrows() {
    class C : MockCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument(name:"arg1"), MockArgument(name:"arg2")]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg1", "--option"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.optionNotAllowedHere(command: cmd, option: "--option") {} else {
      XCTFail()
    }
  }
  
  func testSendTwoArgsWithCommandThatHasOneArgThrows() {
    class C : MockCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument(name:"arg1")]
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "arg1", "arg2"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return }
    if case error = CommandParserError.invalidArgumentOrSubCommand(cmd) {} else {
      XCTFail()
    }
  }
  
  func testParseCommandWithSubcommandExtraArgThrows() {
    class SubCMD : MockSubCommand, CommandWithArguments {
      var arguments : [Argument] = [MockArgument()]
    }
    class C : MockCommand, CommandWithSubCommands {
      var subcommands = SubcommandArray(SubCMD())
      var usedSubcommand : Command?
    }
    let parser = CommandParser()
    try! parser.register(C())
    let cmd = C.init()
    let delegate = MockCommandParserDelegate()
    parser.parse(arguments: ["mockcommand", "mocksubcommand", "mockargvalue", "somethingelse"], delegate: delegate)
    guard let error = delegate.error else { XCTFail(); return } //TODO: Should reflect that invalid arguments are for the subcommand
    if case error = CommandParserError.invalidArgumentOrSubCommand(cmd) {} else {
      XCTFail()
    }
  }
  
  //TODO: Fill this out
  static var allTests : [(String, (ParserRuntimeTests) -> () throws -> Void)] {
    return [
      ("testParseValidCommandWithTwoOptions", testParseValidCommandWithTwoOptions)
    ]
  }
}


