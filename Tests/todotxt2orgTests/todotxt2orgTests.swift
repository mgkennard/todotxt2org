import XCTest
import class Foundation.Bundle

final class todotxt2orgTests: XCTestCase {
    private let converter = TodoTxtConverter()
    
    func testSimple() {
        XCTAssertEqual(converter.convert(input: "Take dog for a walk"), "* Tasks\n** TODO Take dog for a walk")
    }
    
    func testWithPriority() {
        XCTAssertEqual(converter.convert(input: "(B) Take dog for a walk"), "* Tasks\n** TODO [#B] Take dog for a walk")
    }
    
    func testDone() {
        XCTAssertEqual(converter.convert(input: "x Take dog for a walk"), "* Tasks\n** DONE Take dog for a walk")
    }
    
    func testProject() {
        XCTAssertEqual(converter.convert(input: "Take dog for a walk +MrWiggles"), "* MrWiggles\n** TODO Take dog for a walk")
    }
    
    func testMultipleProjects() {
        XCTAssertEqual(converter.convert(input: "Take dog for a walk +MrWiggles +Pets"), "* MrWiggles\n** TODO Take dog for a walk")
    }
    
    func testContexts() {
        XCTAssertEqual(converter.convert(input: "Take dog for a walk @home"), "* Tasks\n** TODO Take dog for a walk :home:")
        XCTAssertEqual(converter.convert(input: "Take dog for a walk @home @park @mrwiggles"), "* Tasks\n** TODO Take dog for a walk :home:park:mrwiggles:")
    }
    
    func testDates() {
        XCTAssertEqual(converter.convert(input: "2018-12-10 Take dog for a walk"), "* Tasks\n** TODO Take dog for a walk\n[2018-12-10]")
        XCTAssertEqual(converter.convert(input: "2018-12-12 2018-12-10 Take dog for a walk"), "* Tasks\n** TODO Take dog for a walk\nCLOSED: [2018-12-12]\n[2018-12-10]")
        XCTAssertEqual(converter.convert(input: "Take dog for a walk due:2018-12-12"), "* Tasks\n** TODO Take dog for a walk\nDEADLINE: <2018-12-12>")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }

    static var allTests = [
        ("testSimple", testSimple),
        ("testWithPriority", testWithPriority),
        ("testDone", testDone),
        ("testProject", testProject),
        ("testMultipleProjects", testMultipleProjects),
        ("testContexts", testContexts),
        ("testDates", testDates)
    ]
}
