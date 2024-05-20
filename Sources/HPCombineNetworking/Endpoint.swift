//
//  File.swift
//
//
//  Created by Huy Pham on 20/05/2024.
//

import Foundation

public protocol Endpoint {
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: RequestMethod { get }
    
    var queryParameters: [String: Any]? { get }
    
    var bodyParameters: BodyParameters? { get }

    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data { get }
    
    /// The type of HTTP task to be performed.
    var task: Task { get }
        
    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}
