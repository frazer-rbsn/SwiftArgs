import XCTest
@testable import SwiftArgs

class ParserRuntimeTests : XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testParseNoCommands() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: [], delegate: delegate)
        XCTAssert(delegate.commandNotSuppliedFlag)
    }
    
    func testParseBlankCommand() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: [""], delegate: delegate)
        XCTAssert(delegate.commandNotSuppliedFlag)
    }
    
    func testParseValidCommandOptionNotSet() {
        let parser = CommandParser()
        let option = MockOption(name: "option")
        let cmd = MockCommandWithOptions(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["generate"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssertFalse(c.options[0].set)
    }
    
    func testParseValidCommandWithOptionWithArgumentEmptyArg() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommandWithOptions(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["generate", "--option="], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssert(c.options[0].set)
        XCTAssert((c.options[0] as! OptionWithArgument).value! == "")
    }
    
    func testParseValidCommandWithTwoOptions() {
        let cmd = MockCommandWithOptions(name: "mockcommand", helptext: "Blah blah!",
                              options: [MockOption(name:"op1"),
                                        MockOption(name:"op2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--op1", "--op2"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssert(c.options[0].set)
        XCTAssert(c.options[1].set)
    }
    
    func testParseValidCommandWithTwoArgs() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              arguments: [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "arg1value", "arg2value"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let command = delegate.command!
        XCTAssertNotNil(command)
        XCTAssertEqual(command.arguments[0].value!, "arg1value")
        XCTAssertEqual(command.arguments[1].value!, "arg2value")
    }
    
    func testParseValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        let cmd = MockCommandWithOptions(name: "mockcommand", helptext: "Blah blah!",
                                         options: [MockOption(name:"op"),
                                                   MockOptionWithArgument(name:"opwitharg")],
                                         arguments: [MockArgument(name:"mockarg")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--op", "--opwitharg=value", "argumentvalue"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssert(c.options[0].set)
        XCTAssert(c.options[1].set)
        XCTAssert((c.options[1] as! OptionWithArgument).value! == "value")
        XCTAssertEqual(c.arguments[0].value!, "argumentvalue")
    }
    
    func testParseValidCommandWithSubcommandWithArgument() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", arguments: [subcmdarg])
        let cmd = MockCommandWithSubCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["command", "subcommand", "subcommandargvalue"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(command == cmd as Command)
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
        XCTAssert(command.usedSubCommand!.arguments[0].value! == "subcommandargvalue")
    }
    
    func testParseValidCommandWithArgumentWithSubcommand() {
        let parser = CommandParser()
        let subcmd = MockCommand(name: "subcommand")
        let cmdarg = MockArgument()
        let cmd = MockCommandWithSubCommand(name: "command", arguments: [cmdarg], subCommands: [subcmd])
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["command", "commandargvalue", "subcommand"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(command == cmd as Command)
        XCTAssert(command.arguments[0].value! == "commandargvalue")
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
    }
    
    func testParseValidCommandWithTwoArgumentsWithSubcommand() {
        let parser = CommandParser()
        let subcmd = MockCommand(name: "subcommand")
        let cmdarg1 = MockArgument(name: "mockarg1")
        let cmdarg2 = MockArgument(name: "mockarg2")
        let cmd = MockCommandWithSubCommand(name: "command", arguments: [cmdarg1, cmdarg2], subCommands: [subcmd])
        try! parser.addCommand(cmd)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["command", "arg1value", "arg2value", "subcommand"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(command == cmd as Command)
        XCTAssert(command.arguments[0].value! == "arg1value")
        XCTAssert(command.arguments[1].value! == "arg2value")
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
    }
    
    
    // MARK: Invalid scenarios
    
    func testParseWithNoRegisteredCommandsThrows() {
        let parser = CommandParser()
        AssertThrows(expectedError: ParserError.noCommands,
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testParseNonExistingCommandThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name:"foo")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noSuchCommand("bar"),
                     try parser.parse(arguments: ["bar"]))
    }
    
    func testParseCommandWithIncorrectOptionName() {
        let parser = CommandParser()
        let op = MockOption(name:"foo")
        let cmd = MockCommandWithOptions(name: "generate", options: [op])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noSuchOption(command: cmd, option: "--bar"),
                     try parser.parse(arguments: ["generate", "--bar"]))
    }
    
    func testParseCommandWithOneOptionNoArgsAsCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", arguments: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testParseCommandWithOneOptionAsCommandThatHasNoOptionsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testParseCommandWithTwoOptionsAsCommandThatHasNoOptionsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option", "--option2"]))
    }
    
    func testParseCommandWithOptionThatRequiresArgumentNoArgThrows() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommandWithOptions(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.optionRequiresArgument(command: cmd, option: option),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testSendNoArgsWithCommandThatRequiresArgsThrows() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", arguments: [arg])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.requiresArguments(cmd),
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSubCommandsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate", arguments: [])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd),
                     try parser.parse(arguments: ["generate", "arg"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSuchSubCommandThrows() {
        let parser = CommandParser()
        let subcmd = MockCommand(name: "foo")
        let cmd = MockCommandWithSubCommand(name: "generate", arguments: [], subCommands: [subcmd])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.noSuchSubCommand(command: cmd, subCommandName: "bar"),
                     try parser.parse(arguments: ["generate", "bar"]))
    }
    
    func testSendOneArgWithCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", arguments: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.invalidArguments(cmd),
                     try parser.parse(arguments: ["generate", "arg1"]))
    }
    
    func testSendOneArgOneOptionAfterArgWithCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", arguments: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.optionNotAllowedHere(command: cmd, option: "--option"),
                     try parser.parse(arguments: ["generate", "arg1", "--option"]))
    }
    
    func testSendTwoArgsWithCommandThatHasOneArgThrows() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", arguments: [arg])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd),
                     try parser.parse(arguments: ["generate", "arg1", "arg2"]))
    }
    
    func testParseCommandWithSubcommandExtraArgThrows() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", arguments: [subcmdarg])
        let cmd = MockCommandWithSubCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd), //TODO: Should reflect that invalid arguments are for the subcommand
                     try parser.parse(arguments: ["command", "subcommand", "mockargvalue", "somethingelse"]))
    }
    
    //TODO: Fill this out
    static var allTests : [(String, (ParserRuntimeTests) -> () throws -> Void)] {
        return [
            ("testParseValidCommandWithTwoOptions", testParseValidCommandWithTwoOptions)
        ]
    }
}


