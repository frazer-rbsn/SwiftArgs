//
//  CommandModelTests.swift
//  SwiftArgs
//
//  Created by Frazer Robinson on 11/11/2016.
//
//

import XCTest
@testable import SwiftArgs

class CommandModelTests: XCTestCase {
    
    func testGetOption() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOption(name:"foo"), MockOption(name:"bar"), MockOption(name:"baz"))
        }
        let c = C.init()
        XCTAssertEqual(try! c.getOption("bar").name, "bar")
    }

    func testOptionLongForms() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOption(name:"foo"), MockOption(name:"bar"), MockOption(name:"baz"))
        }
        let c = C.init()
        XCTAssertEqual(c.optionLongForms,["--foo","--bar","--baz"])
    }
    
    func testSetOption() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOption(name:"foo"))
        }
        var c = C.init()
        XCTAssert(c.usedOptions.count == 0)
        try! c.setOption("--foo")
        XCTAssert(c.usedOptions.count == 1)
    }
    
    func testSetOptionWithArg() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOptionWithArgument(name:"fish"))
        }
        var c = C.init()
        XCTAssert(c.usedOptions.count == 0)
        try! c.setOption("--fish", value: "salmon")
        XCTAssert(c.usedOptions.count == 1)
        XCTAssert((c.usedOptions[0] as! OptionWithArgument).value == "salmon")
    }
    
    
    func testGetNonExistantOptionThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOption(name:"foo"))
        }
        let c = C.init()
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.getOption("fish"))
    }

    func testSetNonExistantOptionThrows() {
        class C : MockCommand, CommandWithOptions {
            var options = OptionSet(MockOption(name:"foo"))
        }
        var c = C.init()
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.setOption("fish"))
    }
}
