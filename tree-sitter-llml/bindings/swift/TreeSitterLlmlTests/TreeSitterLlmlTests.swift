import XCTest
import SwiftTreeSitter
import TreeSitterLlml

final class TreeSitterLlmlTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_llml())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Llml grammar")
    }
}
