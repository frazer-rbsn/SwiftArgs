import XCTest
@testable import SwiftCommandLineKit

class ParserRuntimeTests : XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testParseValidCommandOptionNotSet() {
        let parser = CommandParser()
        let option = MockOption(name: "option")
        let cmd = MockCommand(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["generate"])
        XCTAssertNotNil(command)
        XCTAssertFalse(command.options[0].set)
    }
    
    func testParseValidCommandWithOptionWithArgumentEmptyArg() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommand(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["generate", "--option="])
        XCTAssertNotNil(command)
        XCTAssert(command.options[0].set)
        XCTAssert((command.options[0] as! OptionWithArgument).value! == "")
    }
    
    func testParseValidCommandWithTwoOptions() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              options: [MockOption(name:"op1"),
                                        MockOption(name:"op2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "--op1", "--op2"])
        XCTAssertNotNil(command)
        XCTAssert(command.options[0].set)
        XCTAssert(command.options[1].set)
    }
    
    func testParseValidCommandWithTwoArgs() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "arg1value", "arg2value"])
        XCTAssertNotNil(command)
        XCTAssertEqual(command.arguments[0].value!, "arg1value")
        XCTAssertEqual(command.arguments[1].value!, "arg2value")
    }
    
    func testParseValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg")],
                              options: [MockOption(name:"op"),
                                        MockOptionWithArgument(name:"opwitharg")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "--op", "--opwitharg=value", "argumentvalue"])
        XCTAssertNotNil(command)
        XCTAssert(command.options[0].set)
        XCTAssert(command.options[1].set)
        XCTAssert((command.options[1] as! OptionWithArgument).value! == "value")
        XCTAssertEqual(command.arguments[0].value!, "argumentvalue")
    }
    
    func testParseValidCommandWithSubcommandWithArgument() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", args: [subcmdarg])
        let cmd = MockCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["command", "subcommand", "subcommandargvalue"])
        XCTAssert(command == cmd as Command)
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
        XCTAssert(command.usedSubCommand!.arguments[0].value! == "subcommandargvalue")
    }
    
    func testParseValidCommandWithArgumentWithSubcommand() {
        let parser = CommandParser()
        let subcmd = MockCommand(name: "subcommand")
        let cmdarg = MockArgument()
        let cmd = MockCommand(name: "command", subCommands: [subcmd], args: [cmdarg])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["command", "commandargvalue", "subcommand"])
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
        let cmd = MockCommand(name: "command", subCommands: [subcmd], args: [cmdarg1, cmdarg2])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["command", "arg1value", "arg2value", "subcommand"])
        XCTAssert(command == cmd as Command)
        XCTAssert(command.arguments[0].value! == "arg1value")
        XCTAssert(command.arguments[1].value! == "arg2value")
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
    }
    
    
    // MARK: Invalid scenarios
    
    func testParseWithNoRegisteredCommandsThrows() {
        let parser = CommandParser()
        AssertThrows(expectedError: CommandParser.ParserError.noCommands,
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testParseEmptyArgsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandParser.ParserError.commandNotSupplied,
                     try parser.parse(arguments: []))
    }
    
    func testParseBlankArgThrows() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandParser.ParserError.commandNotSupplied,
                     try parser.parse(arguments: []))
    }
    
    func testParseNonExistingCommandThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name:"foo")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandParser.ParserError.noSuchCommand("bar"),
                     try parser.parse(arguments: ["bar"]))
    }
    
    func testParseCommandWithOneOptionNoArgsAsCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", args: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testParseCommandWithOneOptionAsCommandThatHasNoOptionsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testParseCommandWithTwoOptionsAsCommandThatHasNoOptionsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option", "--option2"]))
    }
    
    func testParseCommandWithOptionThatRequiresArgumentNoArgThrows() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommand(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.optionRequiresArgument(command: cmd, option: option),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testSendNoArgsWithCommandThatRequiresArgsThrows() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", args: [arg])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.requiresArguments(cmd),
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSubCommandsThrows() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate", args: [])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noArgumentsOrSubCommands(cmd),
                     try parser.parse(arguments: ["generate", "arg"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsNoSuchSubCommandThrows() {
        let parser = CommandParser()
        let subcmd = MockCommand(name: "foo")
        let cmd = MockCommand(name: "generate", subCommands: [subcmd], args: [])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noSuchSubCommand(command: cmd, subCommandName: "bar"),
                     try parser.parse(arguments: ["generate", "bar"]))
    }
    
    func testSendOneArgWithCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", args: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.invalidArguments(cmd),
                     try parser.parse(arguments: ["generate", "arg1"]))
    }
    
    func testSendOneArgOneOptionAfterArgWithCommandThatRequiresTwoArgsThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", args: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.invalidArguments(cmd),
                     try parser.parse(arguments: ["generate", "arg1", "--option"]))
    }
    
    func testSendTwoArgsWithCommandThatHasOneArgThrows() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", args: [arg])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noSuchSubCommand(command: cmd, subCommandName: "arg2"),
                     try parser.parse(arguments: ["generate", "arg1", "arg2"]))
    }
    
    func testParseCommandWithSubcommandExtraArgThrows() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", args: [subcmdarg])
        let cmd = MockCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noSuchSubCommand(command: cmd, subCommandName: "somethingelse"),
                     try parser.parse(arguments: ["command", "subcommand", "mockargvalue", "somethingelse"]))
    }
    
    //TODO: Fill this out
    static var allTests : [(String, (ParserRuntimeTests) -> () throws -> Void)] {
        return [
            ("testParseValidCommandWithTwoOptions", testParseValidCommandWithTwoOptions)
        ]
    }
}


