//
//  ParserLogicTests.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 10/11/2016.
//
//

import XCTest
@testable import SwiftCommandLineKit

class ParserLogicTests: XCTestCase {
    
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

}
