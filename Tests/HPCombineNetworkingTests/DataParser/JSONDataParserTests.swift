
import Foundation
@testable import HPCombineNetworking
import XCTest

class JSONDataParserTests: XCTestCase {
    var jsonDataParser: JSONDataParser!
    
    override func setUp() {
        super.setUp()
        jsonDataParser = JSONDataParser()
    }
    
    override func tearDown() {
        jsonDataParser = nil
        super.tearDown()
    }
    
    func testParseValidData() {
        let json = """
        {
            "id": 1,
            "name": "Huy Pham"
        }
        """.data(using: .utf8)!
        
        do {
            let user: User = try jsonDataParser.parse(json)
            XCTAssertEqual(user.id, 1)
            XCTAssertEqual(user.name, "Huy Pham")
        } catch {
            XCTFail("Expected to parse valid data, but failed with error: \(error)")
        }
    }
    
    func testParseInvalidData() {
        let json = """
        {
            "id": "String",
            "name": "Huy Pham"
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try jsonDataParser.parse(json) as User) { error in
            XCTAssertTrue(error is DecodingError, "Expected DecodingError but got \(type(of: error))")
        }
    }
    
    func testParseDataWithSnakeCase() {
        
        struct Name: Codable {
            let firstName: String
            let lastName: String
        }
        
        let json = """
        {
            "first_name": "Pham",
            "last_name": "Huy"
        }
        """.data(using: .utf8)!
        
        jsonDataParser = JSONDataParser()
        
        do {
            let name: Name = try jsonDataParser.parse(json)
            XCTAssertEqual(name.firstName, "Pham")
            XCTAssertEqual(name.lastName, "Huy")
        } catch {
            XCTFail("Expected to parse valid data, but failed with error: \(error)")
        }
    }
}
