
import XCTest
@testable import HPCombineNetworking

class NetworkErrorHandlingTests: XCTestCase {
    var networkErrorHandler: NetworkErrorHandler!
    
    override func setUp() {
        super.setUp()
        networkErrorHandler = NetworkErrorHandler()
    }
    
    override func tearDown() {
        networkErrorHandler = nil
        super.tearDown()
    }
    
    func testHandleDecodingError() {
        let decodeError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        let actualError = networkErrorHandler.handle(decodeError)
        XCTAssertEqual(actualError, NetworkError.decode)
    }
    func testHandleNetworkError_BadRequests() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        let networkError = NetworkError.unexpectedStatusCode(response)
        let actualError = networkErrorHandler.handle(networkError)
        XCTAssertEqual(actualError, NetworkError.badRequest)
    }
    func testSuccessStatusCode() {
        let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let networkError = NetworkError.unexpectedStatusCode(response)
        let actualError = networkErrorHandler.handle(networkError)
        XCTAssertEqual(actualError, NetworkError.unknown)
    }
    
    
}
