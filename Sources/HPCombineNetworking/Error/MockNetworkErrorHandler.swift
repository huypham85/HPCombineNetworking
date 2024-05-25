
import Foundation

class MockNetworkErrorHandler: NetworkErrorHandling {
    var handleStub: ((Error) -> NetworkError)?
    
    func handle(_ error: any Error) -> NetworkError {
        return handleStub?(error) ?? .unknown
    }
    
    
}
