
import Foundation
import XCTest
import HPCombineNetworking

class FormURLEncodedBodyParametersTests: XCTestCase {
    func testURLSuccess() throws {
        let object = ["key1": 1, "key2": 2, "key3": 3]
        let parameters = FormURLEncodedBodyParameters(formObject: object)
        
        // verify the content-type
        XCTAssertEqual(parameters.contentType, "application/x-www-form-urlencoded")
        
        // verify the object after built RequestEntity
        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }
            
            let createdObject = try URLEncodedSerialization.object(from: data, encoding: .utf8)
            XCTAssertEqual(createdObject["key1"], "1")
            XCTAssertEqual(createdObject["key2"], "2")
            XCTAssertEqual(createdObject["key3"], "3")
        } catch {
            XCTFail()
        }
    }
}
