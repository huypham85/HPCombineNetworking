
import Foundation
import XCTest
import HPCombineNetworking

class JSONBodyParametersTests: XCTestCase {
    func testJSONSuccess() throws {
        let object = ["key1": 1, "key2": 2, "key3": 3]
        let parameters = JSONBodyParameters(JSONObject: object)
        
        // verify the content-type
        XCTAssertEqual(parameters.contentType, "application/json")
        
        // verify the object after built RequestEntity
        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
        XCTAssertEqual((dictionary as? [String: Int])?["key1"], 1)
        XCTAssertEqual((dictionary as? [String: Int])?["key2"], 2)
        XCTAssertEqual((dictionary as? [String: Int])?["key3"], 3)
    }
    
    func testJSONFailure() {
        let object = NSObject()
        let parameters = JSONBodyParameters(JSONObject: object)
        
        
        // verify the error thrown by building entity
        XCTAssertThrowsError(try parameters.buildEntity()) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nsError.code, 3840)
        }
    }
}
