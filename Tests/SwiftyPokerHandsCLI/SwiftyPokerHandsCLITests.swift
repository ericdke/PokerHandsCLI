import XCTest
@testable import SwiftyPokerHandsCLI

class SwiftyPokerHandsCLITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SwiftyPokerHandsCLI().text, "Hello, World!")
    }


    static var allTests : [(String, (SwiftyPokerHandsCLITests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
