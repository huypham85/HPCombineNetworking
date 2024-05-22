
import Combine
import Foundation

public protocol NetworkManager {
    func execute<T: Endpoint>(request: T) -> AnyPublisher<T.Response, NetworkError>
}

extension NetworkManager {
    func execute<T: Endpoint>(request: T) -> AnyPublisher<T.Response, NetworkError> where T.Response: Codable {
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildURLRequest()
        } catch {
            return switch error {
            case let error as NetworkError:
                Fail(error: error).eraseToAnyPublisher()
            default:
                Fail(error: NetworkError.unknown).eraseToAnyPublisher()
            }
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse, 200 ... 299 ~= response.statusCode else {
                    throw NetworkError.invalidURL
                }
                return data
            }
            .decode(type: T.Response.self, decoder: JSONDecoder()) // TODO: create a parser
            .mapError { error -> NetworkError in
                if error is DecodingError {
                    return NetworkError.decode
                } else if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
