import XCTest
@testable import SwiftCommandLineKit

class ParserRuntimeTests : XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testAddValidCommandWithTwoOptionsAndParse() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              options: [MockOption(name:"op1"),
                                        MockOption(name:"op2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "--op1", "--op2"])
        XCTAssertNotNil(command)
    }
    
    func testAddValidCommandWithTwoArgsAndParse() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "arg1value", "arg2value"])
        XCTAssertNotNil(command)
    }
    
    func testAddValidCommandWithOneOptionAndOneOptionWithArgAndOneArgAndParse() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg")],
                              options: [MockOption(name:"op"),
                                        MockOptionWithArgument(name:"opwitharg")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["mockcommand", "--op", "--opwitharg=value", "argumentvalue"])
        XCTAssertNotNil(command)
    }
    
    func testParseCommandWithSubcommand() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", args: [subcmdarg])
        let cmd = MockCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["command", "subcommand", "mockargvalue"])
        XCTAssert(command == cmd as Command)
        XCTAssertNotNil(command.usedSubCommand)
        XCTAssert(command.usedSubCommand! == subcmd as Command)
    }
    
    
    // MARK: Invalid scenarios
    
    func testParseCommandWithNoRegisteredCommandsThrowsError() {
        let parser = CommandParser()
        AssertThrows(expectedError: CommandParser.ParserError.noCommands,
                     try parser.parse(arguments: ["generate"]))
    }
    
    func testSendNoArgsToParserThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: []))
    }
    
    func testSendBlankCommandNameToParserThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand()
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: [""]))
    }
    
    func testNonExistingCommandToParserThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand(name:"foo")
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: ["bar"]))
    }
    
    func testSendOneOptionNoArgsWithCommandThatRequiresArgsThrowsError() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", args: [arg1, arg2])
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testSendOneOptionWithCommandThatHasNoOptionsThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testSendTwoOptionsWithCommandThatHasNoOptionsThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate")
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.noOptions(cmd),
                     try parser.parse(arguments: ["generate", "--option", "--option2"]))
    }
    
    func testSendNoArgsWithCommandThatRequiresArgsThrowsError() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", args: [arg])
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: ["generate"]))
    }
    
    func testSendOneArgWithCommandThatHasNoArgsThrowsError() {
        let parser = CommandParser()
        let cmd = MockCommand(name: "generate", args: [])
        try! parser.addCommand(cmd)
        XCTAssertThrowsError(try parser.parse(arguments: ["generate","arg"]))
    }
    
    func testSendOneArgWithCommandThatRequiresTwoArgsThrowsError() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg1")
        let arg2 = MockArgument(name:"arg2")
        let cmd = MockCommand(name: "generate", args: [arg1, arg2])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError:
            CommandError.invalidArguments(cmd),
                     try parser.parse(arguments: ["generate", "arg1"]))
    }
    
    func testSendTwoArgsWithCommandThatHasOneArgThrowsError() {
        let parser = CommandParser()
        let arg = MockArgument()
        let cmd = MockCommand(name: "generate", args: [arg])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError:
            CommandError.invalidArguments(cmd),
                     try parser.parse(arguments: ["generate", "arg1", "arg2"]))
    }
    
    func testSendCommandWithOptionThatRequiresArgumentNoArgThrowsError() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommand(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.optionRequiresArgument(command: cmd, option: option),
                     try parser.parse(arguments: ["generate", "--option"]))
    }
    
    func testSendCommandWithOptionThatRequiresArgumentEmptyArgSuccess() {
        let parser = CommandParser()
        let option = MockOptionWithArgument(name: "option")
        let cmd = MockCommand(name: "generate", options: [option])
        try! parser.addCommand(cmd)
        let command = try! parser.parse(arguments: ["generate", "--option="])
        XCTAssertNotNil(command)
    }
    
    func testParseCommandWithSubcommandExtraArgThrows() {
        let parser = CommandParser()
        let subcmdarg = MockArgument()
        let subcmd = MockCommand(name: "subcommand", args: [subcmdarg])
        let cmd = MockCommand(name: "command", subCommands: [subcmd])
        try! parser.addCommand(cmd)
        AssertThrows(expectedError: CommandError.invalidArguments(cmd),
                     try parser.parse(arguments: ["command", "subcommand", "mockargvalue", "somethingelse"]))
    }
    
    //TODO: Fill this out
    static var allTests : [(String, (ParserRuntimeTests) -> () throws -> Void)] {
        return [
            ("testAddValidCommandWithTwoOptionsAndParse", testAddValidCommandWithTwoOptionsAndParse)
        ]
    }
}


