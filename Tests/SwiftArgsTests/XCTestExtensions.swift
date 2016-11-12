import XCTest

/// Implement pattern matching for ErrorType
public func ~=(lhs: Error, rhs: Error) -> Bool {
    return lhs._domain == rhs._domain
        && lhs._code   == rhs._code
}


func AssertThrows<R>(expectedError: Error, _ closure: @autoclosure () throws -> R) -> () {
    do {
        try closure()
        XCTFail("ASSERTTHROWS: Expected error \"\(expectedError)\", "
            + "but closure succeeded.")
    } catch expectedError {
        // Expected.
    } catch {
        XCTFail("ASSERTTHROWS: Caught error \"\(error)\", "
            + "but not from the expected type "
            + "\"\(expectedError)\".")
    }
}
