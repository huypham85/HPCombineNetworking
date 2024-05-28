
import Combine
import Foundation
@testable import HPCombineNetworking
import XCTest

class NetworkServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var parser: MockDataParser!
    var errorHandler: NetworkErrorHandling!
    var networkService: NetworkService!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        parser = MockDataParser()
        errorHandler = MockNetworkErrorHandler()
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        networkService = NetworkService(parser: parser, errorHandler: errorHandler)
    }
    
    override func tearDown() {
        cancellables = nil
        parser = nil
        errorHandler = nil
        networkService = nil
        super.tearDown()
    }
    
    func testExecute_SuccessfulResponse() {
        // Given
        let user = User(id: 1, name: "Huy")
        let data = try! JSONEncoder().encode(user)
        let response = HTTPURLResponse(url: URL(string: "https://api.example.com/user")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.requestHandler = { _ in
            (response, data)
        }
        
        parser.parseStub = { data in
            try JSONDecoder().decode(User.self, from: data)
        }
        
//        let expectation = self.expectation(description: "Completion handler called")
        
        // When
        let endpoint = GetUserEndpoint()
        networkService.execute(request: endpoint)
            .sink { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got failure with \(error)")
                }
//                expectation.fulfill()
            } receiveValue: { receivedUser in
                // Then
                XCTAssertEqual(receivedUser, user)
            }
            .store(in: &cancellables)
    }
    
    func testExecute_FailureResponse() {}
}
