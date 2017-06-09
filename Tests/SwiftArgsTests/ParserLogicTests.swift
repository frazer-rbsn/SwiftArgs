import XCTest
@testable import SwiftArgs

final class ParserLogicTests: XCTestCase {
  
  func testGetOptionRaw() {
    let parser = CommandParser()
    XCTAssertEqual(parser.getOptionName("--option"),"--option")
    XCTAssertEqual(parser.getOptionName("--option="),"--option")
  }
  
  //    func testGetOptionArgument() {
  //        let parser = CommandParser()
  //        XCTAssertEqual(parser.getOptionArgument("--option=arg"),"arg")
  //        XCTAssertEqual(parser.getOptionArgument("--option="),"")
  //    }
  
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
