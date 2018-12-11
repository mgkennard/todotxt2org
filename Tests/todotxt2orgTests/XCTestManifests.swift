import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(todotxt2orgTests.allTests),
    ]
}
#endif
