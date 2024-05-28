
import Foundation

public protocol Endpoint {
    
    associatedtype Response: Codable
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: RequestMethod { get }
    
    var queryParameters: [String: Any]? { get }
    
    var bodyParameters: BodyParameters? { get }
    
    /// The headers to be used in the request.
    var headers: [String: String] { get }
}

public extension Endpoint {
    func buildURLRequest() throws -> URLRequest {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.percentEncodedQuery = URLEncodedSerialization.string(from: queryParameters)
        }
        
        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
            
            switch try bodyParameters.buildEntity() {
            case .data(let data):
                urlRequest.httpBody = data
                
            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }
        
        urlRequest.url = components.url
        urlRequest.httpMethod = method.rawValue
        //            urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return urlRequest
    }
}

// MARK: - Example instances for testing
public struct User: Codable, Equatable {
    let id: Int
    let name: String
}

public struct GetUserEndpoint: Endpoint {
    public typealias Response = User
    
    init(baseURL: String = "https://example.com", path: String = "/", method: RequestMethod = .get, queryParameters: [String : Any]? = nil, bodyParameters: BodyParameters? = nil, headers: [String : String] = [:]) {
        self.baseURL = URL(string: baseURL)!
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
        self.headers = headers
    }
    
    public var baseURL: URL
    
    public var path: String
    
    public var method: RequestMethod
    
    public var queryParameters: [String : Any]?
    
    public var bodyParameters: BodyParameters?
    
    public var headers: [String : String]
    
}
