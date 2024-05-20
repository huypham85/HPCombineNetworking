//
//  File.swift
//
//
//  Created by Huy Pham on 20/05/2024.
//

import Foundation

/// `JSONBodyParameters` serializes JSON object for HTTP body
public struct JSONBodyParameters: BodyParameters {
    /// The JSON object to be serialized.
    public let JSONObject: Any
    
    /// The writing options for serialization.
    public let writingOptions: JSONSerialization.WritingOptions
    
    /// Returns `JSONBodyParameters` that is initialized with JSON object and writing options.
    public init(JSONObject: Any, writingOptions: JSONSerialization.WritingOptions = []) {
        self.JSONObject = JSONObject
        self.writingOptions = writingOptions
    }
    
    // MARK: - BodyParameters
    
    public var contentType: String {
        return "application/json"
    }
    
    /// Builds `RequestBodyEntity.data` that represents `JSONObject`.
    /// - Throws: `NSError` if `JSONSerialization` fails to serialize `JSONObject`.
    public func buildEntity() throws -> RequestBodyEntity {
        guard JSONSerialization.isValidJSONObject(JSONObject) else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
        }
        
        return .data(try JSONSerialization.data(withJSONObject: JSONObject, options: writingOptions))
    }
    
    
}
