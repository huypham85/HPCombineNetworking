
import Foundation

public protocol DataParser {
    var decoder: JSONDecoder { get }
    func parse<T: Decodable>(_ data: Data) throws -> T
}

public class JSONDataParser: DataParser {
    public var decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    public func parse<T>(_ data: Data) throws -> T where T : Decodable {
        return try decoder.decode(T.self, from: data)
    }
}


