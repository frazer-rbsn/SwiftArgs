//
//  CommandModelTests.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 11/11/2016.
//
//

import XCTest
@testable import SwiftCommandLineKit

class CommandModelTests: XCTestCase {
    
    func testGetOption() {
        let optionfoo = MockOption(name:"foo")
        let optionbar = MockOption(name:"bar")
        let optionbaz = MockOption(name:"baz")
        let c = MockCommand(options:[optionfoo, optionbar, optionbaz])
        XCTAssertEqual(try! c.getOption("bar").name, "bar")
    }

    func testGetNonExistantOptionThrows() {
        let optionfoo = MockOption(name:"foo")
        let optionbar = MockOption(name:"bar")
        let optionbaz = MockOption(name:"baz")
        let c = MockCommand(options:[optionfoo, optionbar, optionbaz])
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.getOption("fish"))
    }

    func testSetNonExistantOptionThrows() {
        let optionfoo = MockOption(name:"foo")
        let optionbar = MockOption(name:"bar")
        let optionbaz = MockOption(name:"baz")
        var c = MockCommand(options:[optionfoo, optionbar, optionbaz])
        AssertThrows(expectedError: CommandError.noSuchOption(command: c, optionName: "fish"),
                     try c.setOption("fish"))
    }
}
