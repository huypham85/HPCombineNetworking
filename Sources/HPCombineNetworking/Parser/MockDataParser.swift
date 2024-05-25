
import Foundation

class MockDataParser: DataParser {
    var decoder: JSONDecoder
    var parseStub: ((Data) throws -> Any)?
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func parse<T>(_ data: Data) throws -> T where T : Decodable {
        if let stub = parseStub {
            return try stub(data) as! T
        } else {
            throw NetworkError.decode
        }
    }
}
