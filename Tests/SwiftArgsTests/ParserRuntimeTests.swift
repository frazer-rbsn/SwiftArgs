import XCTest
@testable import SwiftArgs

class ParserRuntimeTests : XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testParseNoCommands() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: [], delegate: delegate)
        XCTAssert(delegate.commandNotSuppliedFlag)
    }
    
    func testParseBlankCommand() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: [""], delegate: delegate)
        XCTAssert(delegate.commandNotSuppliedFlag)
    }
    
    func testParseValidCommandOptionNotSet() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption())
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssertFalse(c.options[0].used)
        XCTAssert(c.usedOptions.count == 0)
    }
    
    func testParseValidCommandWithOptionWithArgumentNoEqualsSign() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOptionWithArgument())
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--mockoptionwitharg", "arg"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssert(c.options[0].used)
        XCTAssert((c.options[0].option as! OptionWithArgument).value! == "arg")
        XCTAssert(c.usedOptions.count == 1)
    }
    
    func testParseValidCommandWithOptionWithArgumentEmptyArg() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOptionWithArgument())
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--mockoptionwitharg="], delegate: delegate)
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
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--op1", "--op2"], delegate: delegate)
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
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "arg1value", "arg2value"], delegate: delegate)
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
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--mockoption", "--mockoptionwitharg=value", "argumentvalue"], delegate: delegate)
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
            var subcommands : [Command] = [SubCMD()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "mocksubcommand", "subcommandargvalue"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(type(of:command) == C.self)
        XCTAssertNotNil(command.usedSubcommand)
        XCTAssert(type(of:command.usedSubcommand!).name == SubCMD.name)
        XCTAssert((command.usedSubcommand! as! CommandWithArguments).arguments[0].value! == "subcommandargvalue")
    }
    
    func testParseValidCommandWithArgumentWithSubcommand() {
        class C : MockCommand, CommandWithArguments, CommandWithSubCommands {
            var arguments : [Argument] = [MockArgument()]
            var subcommands : [Command] = [MockSubCommand()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "commandargvalue", "mocksubcommand"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(type(of:command) == C.self)
        XCTAssert((command as! CommandWithArguments).arguments[0].value! == "commandargvalue")
        XCTAssertNotNil(command.usedSubcommand)
        XCTAssert(type(of:command.usedSubcommand!).name == MockSubCommand.name)
    }
    
    func testParseValidCommandWithTwoArgumentsWithSubcommand() {
        class C : MockCommand, CommandWithArguments, CommandWithSubCommands {
            var arguments : [Argument] = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
            var subcommands : [Command] = [MockSubCommand()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "arg1value", "arg2value", "mocksubcommand"], delegate: delegate)
        let command = delegate.command! as! CommandWithSubCommands
        XCTAssert(type(of:command) == C.self)
        XCTAssert((command as! CommandWithArguments).arguments[0].value! == "arg1value")
        XCTAssert((command as! CommandWithArguments).arguments[1].value! == "arg2value")
        XCTAssertNotNil(command.usedSubcommand)
        XCTAssert(type(of:command.usedSubcommand!).name == MockSubCommand.name)
    }
    
    func testParseValidCommandWithOneOptionWithArgAndSubcommand() {
        class C : MockCommand, CommandWithOptions, CommandWithSubCommands {
            var options = OptionArray(MockOptionWithArgument())
            var subcommands : [Command] = [MockSubCommand()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let delegate = MockCommandParserDelegate()
        try! parser.parse(arguments: ["mockcommand", "--mockoptionwitharg", "arg", "mocksubcommand"], delegate: delegate)
        XCTAssertNotNil(delegate.command)
        let c = delegate.command as! CommandWithOptions
        XCTAssert(c.options[0].used)
        XCTAssert((c.options[0].option as! OptionWithArgument).value! == "arg")
        let cs = delegate.command as! CommandWithSubCommands
        XCTAssertNotNil(cs.usedSubcommand)
        XCTAssert(type(of:cs.usedSubcommand!).name == MockSubCommand.name)
    }
    
    // MARK: Invalid scenarios
    
    func testParseWithNoRegisteredCommandsThrows() {
        let parser = CommandParser()
        AssertThrows(expectedError: ParserError.noCommands,
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testParseNonExistingCommandThrows() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        AssertThrows(expectedError: ParserError.noSuchCommand("foo"),
                     try parser.parse(arguments: ["foo"]))
    }
    
    func testParseCommandWithIncorrectOptionNameThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"foo"))
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.noSuchOption(command: cmd, option: "--bar"),
                     try parser.parse(arguments: ["mockcommand", "--bar"]))
    }
    
    func testParseCommandWithOneOptionAsCommandThatHasNoOptionsThrows() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        let cmd = MockCommand.init()
        AssertThrows(expectedError: ParserError.noOptions(cmd),
                     try parser.parse(arguments: ["mockcommand", "--option"]))
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
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.optionRequiresArgument(command: cmd, option: cmd.op),
                     try parser.parse(arguments: ["mockcommand", "--op"]))
    }
    
    func testSendNoArgsWithCommandThatRequiresArgsThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument()]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.requiresArguments(cmd),
                     try parser.parse(arguments: ["mockcommand"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSubCommandsThrows() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        let cmd = MockCommand.init()
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd),
                     try parser.parse(arguments: ["mockcommand", "arg"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSuchSubCommandThrows() {
        class C : MockCommand, CommandWithSubCommands {
            var subcommands : [Command] = [MockSubCommand()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.noSuchSubCommand(command: cmd, subcommandName: "bar"),
                     try parser.parse(arguments: ["mockcommand", "notmocksubcommand"]))
    }
    
    func testSendOneArgWithCommandThatRequiresTwoArgsThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg1"), MockArgument(name:"arg2")]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.invalidArguments(cmd),
                     try parser.parse(arguments: ["mockcommand", "arg1"]))
    }
    
    func testSendOneArgOneOptionAfterArgWithCommandThatRequiresTwoArgsThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg1"), MockArgument(name:"arg2")]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.optionNotAllowedHere(command: cmd, option: "--option"),
                     try parser.parse(arguments: ["mockcommand", "arg1", "--option"]))
    }
    
    func testSendTwoArgsWithCommandThatHasOneArgThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg1")]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd),
                     try parser.parse(arguments: ["mockcommand", "arg1", "arg2"]))
    }
    
    func testParseCommandWithSubcommandExtraArgThrows() {
        class SubCMD : MockSubCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument()]
        }
        class C : MockCommand, CommandWithSubCommands {
            var subcommands : [Command] = [SubCMD()]
            var usedSubcommand : Command?
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        let cmd = C.init()
        AssertThrows(expectedError: ParserError.invalidArgumentOrSubCommand(cmd), //TODO: Should reflect that invalid arguments are for the subcommand
                     try parser.parse(arguments: ["mockcommand", "mocksubcommand", "mockargvalue", "somethingelse"]))
    }
    
    //TODO: Fill this out
    static var allTests : [(String, (ParserRuntimeTests) -> () throws -> Void)] {
        return [
            ("testParseValidCommandWithTwoOptions", testParseValidCommandWithTwoOptions)
        ]
    }
}


