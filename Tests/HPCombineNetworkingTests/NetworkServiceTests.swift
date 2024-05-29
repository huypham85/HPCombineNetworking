
import Combine
import Foundation
@testable import HPCombineNetworking
import XCTest

class NetworkServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!
    var parser: MockDataParser!
    var errorHandler: MockNetworkErrorHandler!
    var networkService: NetworkService!
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        parser = MockDataParser()
        errorHandler = MockNetworkErrorHandler()
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        
        networkService = NetworkService(parser: parser, errorHandler: errorHandler, session: session)
    }
    
    override func tearDown() {
        cancellables = nil
        parser = nil
        errorHandler = nil
        networkService = nil
        session = nil
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
        
        let expectation = self.expectation(description: "Completion handler called")
        
        // When
        let endpoint = GetUserEndpoint()
        networkService.execute(request: endpoint)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    XCTFail("Expected success, got failure with \(error)")
                }
                // Fulfill the expectation when the operation completes
                expectation.fulfill()
            }, receiveValue: { receivedUser in
                // Then
                XCTAssertEqual(receivedUser, user)
            })
            .store(in: &cancellables)
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testExecute_FailureResponse() {
        // Given
        let user = User(id: 1, name: "Huy")
        let data = try! JSONEncoder().encode(user)
        let response = HTTPURLResponse(url: URL(string: "https://api.example.com/user")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        MockURLProtocol.requestHandler = { _ in
            (response, data)
        }
        
        errorHandler.handleStub = { error in
            return .notFound
        }
        
        let expectation = self.expectation(description: "Completion handler called")
        
        // When
        let endpoint = GetUserEndpoint()
        networkService.execute(request: endpoint)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // Then
                    XCTAssertEqual(error, NetworkError.notFound)
                } else {
                    XCTFail("Expected failure, got success")
                }
                // Fulfill the expectation when the operation completes
                expectation.fulfill()
            }, receiveValue: { receivedUser in
                XCTFail("Expected failure, got success")
            })
            .store(in: &cancellables)
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
