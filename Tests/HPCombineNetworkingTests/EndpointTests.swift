
import Foundation
import XCTest
@testable import HPCombineNetworking

class EndpointTests: XCTestCase {
    func testJapanesesQueryParameters() throws {
        let request = GetUserEndpoint(queryParameters: ["q": "こんにちは"])
        let urlRequest = try request.buildURLRequest()
        XCTAssertEqual(urlRequest.url?.query, "q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF")
    }
    
    func testSymbolQueryParameters() throws {
        let request = GetUserEndpoint(queryParameters: ["q": "!\"#$%&'()0=~|`{}*+<>?/_"])
        let urlRequest = try request.buildURLRequest()
        XCTAssertEqual(urlRequest.url?.query, "q=%21%22%23%24%25%26%27%28%290%3D~%7C%60%7B%7D%2A%2B%3C%3E?/_")
    }
    
    func testNullQueryParameters() throws {
        let request = GetUserEndpoint(queryParameters: ["null": NSNull()])
        let urlRequest = try request.buildURLRequest()
        XCTAssertEqual(urlRequest.url?.query, "null")
    }
    
    func testheaderFields() throws {
        let request = GetUserEndpoint(headers: ["Foo": "f", "Accept": "a", "Content-Type": "c"])
        let urlReqeust = try request.buildURLRequest()
        XCTAssertEqual(urlReqeust.value(forHTTPHeaderField: "Foo"), "f")
        XCTAssertEqual(urlReqeust.value(forHTTPHeaderField: "Accept"), "a")
        XCTAssertEqual(urlReqeust.value(forHTTPHeaderField: "Content-Type"), "c")
    }
    
    func testPOSTJSONRequest() throws {
        let parameters: [Any] = [
            ["id": "1"],
            ["id": "2"],
            ["hello", "yellow"]
        ]
        
        let request = GetUserEndpoint(method: .post, bodyParameters: JSONBodyParameters(JSONObject: parameters))
        
        let urlRequest = try request.buildURLRequest()
        
        let json = urlRequest.httpBody.flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) } as? [AnyObject]
        XCTAssertEqual(json?.count, 3)
        XCTAssertEqual((json?[0] as? [String: String])?["id"], "1")
        XCTAssertEqual((json?[1] as? [String: String])?["id"], "2")
        
        let array = json?[2] as? [String]
        XCTAssertEqual(array?[0], "hello")
        XCTAssertEqual(array?[1], "yellow")
    }
    
    func testPOSTInvalidJSONRequest() {
        let request = GetUserEndpoint(method: .post, bodyParameters: JSONBodyParameters(JSONObject: "foo"))
        let urlRequest = try? request.buildURLRequest()
        XCTAssertNil(urlRequest?.httpBody)
    }
    
    func testBuildURL() {
        // MARK: - baseURL = https://example.com
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "").absoluteURL,
            URL(string: "https://example.com")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/").absoluteURL,
            URL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "foo").absoluteURL,
            URL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/foo/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/bar", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/foo/bar/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/bar/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com", path: "/foo/bar//").absoluteURL,
            URL(string: "https://example.com/foo/bar//")
        )
        
        // MARK: - baseURL = https://example.com/
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "").absoluteURL,
            URL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/").absoluteURL,
            URL(string: "https://example.com//")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "foo").absoluteURL,
            URL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo").absoluteURL,
            URL(string: "https://example.com//foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/").absoluteURL,
            URL(string: "https://example.com//foo/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com//foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/bar", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com//foo/bar/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "/foo/bar/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "").absoluteURL,
            URL(string: "https://example.com/api")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/").absoluteURL,
            URL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/api/foo/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/bar", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/api/foo/bar/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "/foo/bar/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/api/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api/
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "").absoluteURL,
            URL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/").absoluteURL,
            URL(string: "https://example.com/api//")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "foo").absoluteURL,
            URL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo").absoluteURL,
            URL(string: "https://example.com/api//foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/").absoluteURL,
            URL(string: "https://example.com/api//foo/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com/api//foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/bar", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com/api//foo/bar/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "/foo/bar/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com/api//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com/api/", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com/api/foo//bar//")
        )
        
        //　MARK: - baseURL = https://example.com///
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "").absoluteURL,
            URL(string: "https://example.com///")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/").absoluteURL,
            URL(string: "https://example.com////")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "foo").absoluteURL,
            URL(string: "https://example.com///foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo").absoluteURL,
            URL(string: "https://example.com////foo")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/").absoluteURL,
            URL(string: "https://example.com////foo/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "foo/bar").absoluteURL,
            URL(string: "https://example.com///foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/bar").absoluteURL,
            URL(string: "https://example.com////foo/bar")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/bar", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/bar?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/bar/").absoluteURL,
            URL(string: "https://example.com////foo/bar/")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "/foo/bar/", queryParameters: ["p": 1]).absoluteURL,
            URL(string: "https://example.com////foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            GetUserEndpoint(baseURL: "https://example.com///", path: "foo//bar//").absoluteURL,
            URL(string: "https://example.com///foo//bar//")
        )
    }
}
