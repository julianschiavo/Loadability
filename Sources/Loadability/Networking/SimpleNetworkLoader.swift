import Combine
import Foundation

/// A type that can load data from over the network and throw errors.
@MainActor
public protocol SimpleNetworkLoader: Loader {
    /// Creates a `URLRequest` for a network loading request.
    /// - Parameter key: The key identifying the object to load.
    func createRequest(for key: Key) -> URLRequest
    
    /// Decodes data received from a network request into the object.
    /// - Parameters:
    ///   - data: The data received from the request.
    ///   - key: The key identifying the object to load.
    func decode(_ data: Data, key: Key) throws -> Object
}

public extension SimpleNetworkLoader {
    /// Creates a publisher that loads the object.
    /// - Parameter key: The key identifying the object to load.
    func createPublisher(key: Key) -> AnyPublisher<Object, Error>? {
        let request = createRequest(for: key)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .retry(3)
            .tryMap { data, response in
                try self.decode(data, key: key)
            }
            .eraseToAnyPublisher()
    }
}

public extension SimpleNetworkLoader where Object: Codable {
    func decode(_ data: Data, key: Key) throws -> Object {
        let decoder = JSONDecoder()
        return try decoder.decode(Object.self, from: data)
    }
}
