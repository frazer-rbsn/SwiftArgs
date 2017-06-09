import XCTest

/// Implement pattern matching for ErrorType
public func ~=(l: Error, r: Error) -> Bool {
    return l._domain == r._domain && l._code == r._code
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
