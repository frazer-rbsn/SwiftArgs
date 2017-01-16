import XCTest
import Foundation
@testable import SwiftArgs

class CommandValidationTests: XCTestCase {
    
    // MARK: Valid scenarios
    
    func testAddValidCommand() {
        let parser = CommandParser()
        try! parser.register(MockCommand())
        XCTAssert(parser.commands.contains(where: { $0 == MockCommand() }))
    }
    
    func testAddValidCommandWithTwoOptions() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"op1"), MockOption(name:"op2"))
        }
        let parser = CommandParser()
        try! parser.register(C())
        XCTAssert(parser.commands.contains(where: { $0 == C() }))
    }
    
    func testAddValidCommandWithTwoArguments() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"mockarg1"), MockArgument(name:"mockarg2")]
        }
        let parser = CommandParser()
        try! parser.register(C())
        XCTAssert(parser.commands.contains(where: { $0 == C() }))
    }
    
    func testAddValidCommandWithOneOptionAndOneOptionWithArgAndOneArg() {
        class C : MockCommand, CommandWithOptions, CommandWithArguments {
            var options = OptionArray(MockOption(name:"op"), MockOptionWithArgument(name:"opwitharg"))
            var arguments : [Argument] = [MockArgument(name:"mockarg")]
        }
        let parser = CommandParser()
        try! parser.register(C())
        XCTAssert(parser.commands.contains(where: { $0 == C() }))
    }
    
    
    // MARK: Invalid scenarios
    
    func testAddCommandNameWithSpaceThrows() {
        struct C : Command {
            var name = "gener ate"
            var helpText = ""
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testAddEmptyCommandNameThrows() {
        struct C : Command {
            var name = ""
            var helpText = ""
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testDuplicateCommandClassThrows() {
        let parser = CommandParser()
        try! parser.register(MockCommand())
        AssertThrows(expectedError: ParserError.duplicateCommand,
                     try parser.register(MockCommand()))
    }
    
    func testDuplicateCommandNameThrows() {
        struct C : Command {
            var name = "foo"
            var helpText = ""
        }
        struct D : Command {
            var name = "foo"
            var helpText = ""
        }
        let parser = CommandParser()
        try! parser.register(C())
        AssertThrows(expectedError: ParserError.duplicateCommand,
                     try parser.register(D()))
    }
    
    func testNoOptionsThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray()
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testNoArgumentsThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = []
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testNoSubCommandsThrows() {
        class C : MockCommand, CommandWithSubCommands {
            var subcommands: SubcommandArray = SubcommandArray()
            var usedSubcommand: Command?
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testEmptyOptionNameThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:""))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testEmptyArgumentNameThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testDuplicateOptionNamesThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(),MockOption())
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testDuplicateArgumentNamesThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(),MockArgument()]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testOptionNameWithSpaceThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"opt ion"))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testArgumentNameWithSpaceThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg ument")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testOptionNameWithHyphenThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionArray(MockOption(name:"opt-ion"))
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
    
    func testArgumentNameWithHyphenThrows() {
        class C : MockCommand, CommandWithArguments {
            var arguments : [Argument] = [MockArgument(name:"arg-ument")]
        }
        let parser = CommandParser()
        AssertThrows(expectedError:  CommandModelError.invalidCommand,
                     try parser.register(C()))
    }
}
