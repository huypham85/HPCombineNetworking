import Foundation
import Combine

public protocol NetworkErrorHandling {
    func handle(_ error: Error) -> NetworkError
}

public class NetworkErrorHandler: NetworkErrorHandling {
    
    public init() {}
    
    public func handle(_ error: Error) -> NetworkError {
        switch error {
        case is DecodingError:
            return .decode
        case let networkError as NetworkError:
            return handleNetworkError(networkError)
        default:
            return .unknown
        }
    }
    
    private func handleNetworkError(_ networkError: NetworkError) -> NetworkError {
        switch networkError {
        case let .unexpectedStatusCode(httpResponse):
            switch httpResponse.statusCode {
            case 400:
                return .badRequest
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 500:
                return .serverError
            case 200...299:
                return .unknown // This should not happen since we are handling 200...299 as successful responses.
            default:
                return .custom("Received HTTP status code \(httpResponse.statusCode)")
            }
            
        default:
            return .unknown
        }
    }
}

