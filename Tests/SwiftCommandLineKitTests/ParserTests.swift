import XCTest
@testable import SwiftCommandLineKit

class ParserTests : XCTestCase {

    
    // MARK: Parser setup tests
    
    func testAddValidCommand() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument()], options: [MockOption(), MockOptionWithArgument()])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }

    func testAddCommandNameWithSpaceThrowsError() {
        let cmd = MockCommand(name: "gener ate")
        let parser = CommandParser()
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testAddEmptyCommandNameThrowsError() {
        let cmd = MockCommand(name: "")
        let parser = CommandParser()
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateCommandNameThrowsError() {
        let cmd1 = MockCommand(name: "generate")
        let cmd2 = MockCommand(name: "generate")
        let parser = CommandParser()
        try! parser.addCommand(cmd1)
        AssertThrows(expectedError: CommandParser.ParserError.duplicateCommand,
                     try parser.addCommand(cmd2))
    }
    
    func testEmptyOptionNameThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"")
        let cmd = MockCommand(options: [op1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testEmptyArgumentNameThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"")
        let cmd = MockCommand(args: [arg1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateOptionNamesThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"option")
        let op2 = MockOption(name:"option")
        let cmd = MockCommand(options: [op1, op2])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateArgumentNamesThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg")
        let arg2 = MockArgument(name:"arg")
        let cmd = MockCommand(args: [arg1, arg2])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testOptionNameWithSpaceThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"op tion")
        let cmd = MockCommand(options: [op1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testArgumentNameWithSpaceThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg ument")
        let cmd = MockCommand(args: [arg1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testOptionNameWithHyphenThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"op-tion")
        let cmd = MockCommand(options: [op1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testArgumentNameWithHyphenThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg-ument")
        let cmd = MockCommand(args: [arg1])
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    
    // MARK: Parser logic tests
    
    func testGetOptionRaw() {
        let parser = CommandParser()
        XCTAssertEqual(parser.getOptionRaw("--option"),"--option")
        XCTAssertEqual(parser.getOptionRaw("--option="),"--option")
    }
    
    func testGetOptionArgument() {
        let parser = CommandParser()
        XCTAssertEqual(parser.getOptionArgument("--option=arg"),"arg")
        XCTAssertEqual(parser.getOptionArgument("--option="),"")
    }
    
    func testIsOption() {
        let parser = CommandParser()
        XCTAssert(parser.isLongformOption("--option"))
        XCTAssert(parser.isLongformOption("--オプション"))
        XCTAssertFalse(parser.isLongformOption("option"))
        XCTAssertFalse(parser.isLongformOption("-"))
        XCTAssertFalse(parser.isLongformOption("-o"))
        XCTAssertFalse(parser.isLongformOption(""))
    }
    
    
    // MARK: Parser runtime tests
    
    func testParseCommandWithNoRegisteredCommandsThrowsError() {
        let parser = CommandParser()
        AssertThrows(expectedError: CommandParser.ParserError.noCommands,
                     try parser.parse(arguments: ["generate"]))
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
    
    static var allTests : [(String, (ParserTests) -> () throws -> Void)] {
        return [
            ("testAddValidCommand", testAddValidCommand),
            ("testAddCommandNameWithSpaceThrowsError", testAddCommandNameWithSpaceThrowsError),
            ("testAddEmptyCommandNameThrowsError", testAddEmptyCommandNameThrowsError),
            ("testParseCommandWithNoRegisteredCommandsThrowsError", testParseCommandWithNoRegisteredCommandsThrowsError),
            ("testEmptyOptionNameThrows", testEmptyOptionNameThrows),
            ("testEmptyArgumentNameThrows", testEmptyArgumentNameThrows)
        ]
    }
}
