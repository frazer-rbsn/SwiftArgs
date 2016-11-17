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
            var options : [Option] = [MockOption(name:"foo"), MockOption(name:"bar"), MockOption(name:"baz")]
        }
        let c = C.init()
        XCTAssertEqual(try! c.getOption("bar").name, "bar")
    }

    func testGetNonExistantOptionThrows() {
        class C : MockCommand, CommandWithOptions {
            var options : [Option] = [MockOption(name:"foo")]
        }
        let c = C.init()
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.getOption("fish"))
    }

    func testSetNonExistantOptionThrows() {
        class C : MockCommand, CommandWithOptions {
            var options : [Option] = [MockOption(name:"foo")]
        }
        var c = C.init()
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.setOption("fish"))
    }
}
