
import Foundation

protocol DataParser {
    var decoder: JSONDecoder { get }
    func parse<T: Decodable>(_ data: Data) throws -> T
}

class JSONDataParser: DataParser {
    var decoder: JSONDecoder
    
    public init(decoder: JSONDecoder) {
        self.decoder = decoder
    }
    
    func parse<T>(_ data: Data) throws -> T where T : Decodable {
        return try decoder.decode(T.self, from: data)
    }
}


