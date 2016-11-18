//
//  CommandValidationTests.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import XCTest
import Foundation
@testable import SwiftArgs

class CommandValidationTests: XCTestCase {
    
    // MARK: Valid scenarios
    
    func testAddValidCommand() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        XCTAssert(parser.commands.contains(where: { $0 == MockCommand.self }))
    }
    
    func testAddValidCommandWithTwoOptions() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"op1"), MockOption(name:"op2"))
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        XCTAssert(parser.commands.contains(where: { $0 == C.self }))
    }
    
    func testAddValidCommandWithTwoArguments() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        XCTAssert(parser.commands.contains(where: { $0 == C.self }))
    }
    
    func testAddValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        class C : MockCommand, CommandWithOptions, CommandWithArguments {
            var options = OptionArray(MockOption(name:"op"), MockOptionWithArgument(name:"opwitharg"))
            var arguments : [Argument] = [MockArgument(name:"mockarg")]
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        XCTAssert(parser.commands.contains(where: { $0 == C.self }))
    }
    
    
    // MARK: Invalid scenarios
    
    func testAddCommandNameWithSpaceThrows() {
        struct C : Command {
            static var name = "gener ate"
            var helpText = ""
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testAddEmptyCommandNameThrows() {
        struct C : Command {
            static var name = ""
            var helpText = ""
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testDuplicateCommandClassThrows() {
        let parser = CommandParser()
        try! parser.register(MockCommand.self)
        AssertThrows(expectedError: ParserError.duplicateCommand,
                     try parser.register(MockCommand.self))
    }
    
    func testDuplicateCommandNameThrows() {
        struct C : Command {
            static var name = "foo"
            var helpText = ""
        }
        struct D : Command {
            static var name = "foo"
            var helpText = ""
        }
        let parser = CommandParser()
        try! parser.register(C.self)
        AssertThrows(expectedError: ParserError.duplicateCommand,
                     try parser.register(D.self))
    }
    
    func testNoOptionsThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray()
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testNoArgumentsThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = []
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testNoSubCommandsThrows() {
        class C : MockCommand, CommandWithSubCommands {
            var subcommands: [Command] = []
            var usedSubcommand: Command?
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testEmptyOptionNameThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:""))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testEmptyArgumentNameThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testDuplicateOptionNamesThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(),MockOption())
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testDuplicateArgumentNamesThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(),MockArgument()]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testOptionNameWithSpaceThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"opt ion"))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testArgumentNameWithSpaceThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg ument")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testOptionNameWithHyphenThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"opt-ion"))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
    
    func testArgumentNameWithHyphenThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg-ument")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C.self))
    }
}
