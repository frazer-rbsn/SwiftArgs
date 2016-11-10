//
//  CommandValidationTests.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import XCTest
@testable import SwiftCommandLineKit

class CommandValidationTests: XCTestCase {
    
    
    // MARK: Valid scenarios
    
    func testAddValidCommand() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument()], options: [MockOption(), MockOptionWithArgument()])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithTwoOptions() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              options: [MockOption(name:"op1"),
                                        MockOption(name:"op2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithTwoArgs() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    func testAddValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        let cmd = MockCommand(name: "mockcommand", helptext: "Blah blah!",
                              args: [MockArgument(name:"mockarg")],
                              options: [MockOption(name:"op"),
                                        MockOptionWithArgument(name:"opwitharg")])
        let parser = CommandParser()
        try! parser.addCommand(cmd)
        XCTAssert(parser.commands.contains(where: { $0 == cmd }))
    }
    
    
    // MARK: Invalid scenarios
    
    func testAddCommandNameWithSpaceThrows() {
        let cmd = MockCommand(name: "gener ate")
        let parser = CommandParser()
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testAddEmptyCommandNameThrows() {
        let cmd = MockCommand(name: "")
        let parser = CommandParser()
        AssertThrows(expectedError: CommandValidator.ModelError.invalidCommand,
                     try parser.addCommand(cmd))
    }
    
    func testDuplicateCommandNameThrows() {
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
}
