
import Combine
import Foundation

public protocol Networkable {
    func execute<T: Endpoint>(request: T) -> AnyPublisher<T.Response, NetworkError>
}

public final class NetworkService: Networkable {
    private let parser: DataParser
    private let errorHandler: NetworkErrorHandling
    private let session: URLSession
    
    public init(
        parser: DataParser,
        errorHandler: NetworkErrorHandling,
        session: URLSession = .shared
    ) {
        self.parser = parser
        self.errorHandler = errorHandler
        self.session = session
    }
    
    public func execute<T: Endpoint>(request: T) -> AnyPublisher<T.Response, NetworkError> where T.Response: Codable {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildURLRequest()
        } catch {
            return Fail(error: error as? NetworkError ?? NetworkError.unknown).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { [weak self] data, response -> T.Response in
                guard let self = self else {
                    throw NetworkError.unknown
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidURL
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.unexpectedStatusCode(httpResponse)
                }
                return try self.parser.parse(data)
            }
            .mapError { [weak self] error -> NetworkError in
                guard let self else {
                    return NetworkError.unknown
                }
                return self.errorHandler.handle(error)
            }
            .eraseToAnyPublisher()
    }
}
