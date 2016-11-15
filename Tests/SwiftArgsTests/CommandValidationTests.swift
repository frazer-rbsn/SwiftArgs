//
//  CommandValidationTests.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import XCTest
@testable import SwiftArgs

class CommandValidationTests: XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testAddValidCommand() {
        let cmd = MockCommand()
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithTwoOptions() {
        let cmd = MockCommandWithOptions()
        cmd.options = [MockOption(name:"op1"), MockOption(name:"op2")]
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithTwoArgs() {
        let cmd = MockCommandWithArguments()
        cmd.arguments = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        let cmd = MockCommandWithOptionsAndArguments()
        cmd.options = [MockOption(name:"op"), MockOptionWithArgument(name:"opwitharg")]
        cmd.arguments = [MockArgument(name:"mockarg")]
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    
    // MARK: Invalid scenarios
    
    func testAddCommandNameWithSpaceThrows() {
        let cmd = MockCommand()
        cmd.name = "gener ate"
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testAddEmptyCommandNameThrows() {
        let cmd = MockCommand()
        cmd.name = ""
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateCommandNameThrows() {
        let cmd1 = MockCommand()
        cmd1.name = "foo"
        let cmd2 = MockCommand()
        cmd2.name = "foo"
        let parser = CommandParser()
        try! parser.addCommand(cmd1)
        AssertThrows(expectedError: ParserError.duplicateCommand,
                     try parser.addCommand(cmd2))
    }
    
    func testNoOptionsThrows() {
        let parser = CommandParser()
        let cmd = MockCommandWithOptions()
        cmd.options = []
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testNoArgumentsThrows() {
        let parser = CommandParser()
        let cmd = MockCommandWithArguments()
        cmd.arguments = []
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testNoSubCommandsThrows() {
        let parser = CommandParser()
        let cmd = MockCommandWithSubCommands()
        cmd.subCommands = []
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testEmptyOptionNameThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"")
        let cmd = MockCommandWithOptions()
        cmd.options = [op1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testEmptyArgumentNameThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"")
        let cmd = MockCommandWithArguments()
        cmd.arguments = [arg1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateOptionNamesThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"option")
        let op2 = MockOption(name:"option")
        let cmd = MockCommandWithOptions()
        cmd.options = [op1,op2]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateArgumentNamesThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg")
        let arg2 = MockArgument(name:"arg")
        let cmd = MockCommandWithArguments()
        cmd.arguments = [arg1,arg2]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testOptionNameWithSpaceThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"op tion")
        let cmd = MockCommandWithOptions()
        cmd.options = [op1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testArgumentNameWithSpaceThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg ument")
        let cmd = MockCommandWithArguments()
        cmd.arguments = [arg1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testOptionNameWithHyphenThrows() {
        let parser = CommandParser()
        let op1 = MockOption(name:"op-tion")
        let cmd = MockCommandWithOptions()
        cmd.options = [op1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testArgumentNameWithHyphenThrows() {
        let parser = CommandParser()
        let arg1 = MockArgument(name:"arg-ument")
        let cmd = MockCommandWithArguments()
        cmd.arguments = [arg1]
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
}
