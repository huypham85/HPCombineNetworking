import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    // Determine if this protocol can handle the given request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // Return the canonical version of the request
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    // Start loading the request
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Request handler is not set.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    // Stop loading the request
    override func stopLoading() {}
}
