import Foundation

/// A type that can load data from over the network and throw errors.
@MainActor
public protocol SimpleNetworkLoader: Loader {
    /// Creates a `URLRequest` for a network loading request.
    /// - Parameter key: The key identifying the object to load.
    func createRequest(for key: Key) async -> URLRequest
    
    /// Decodes data received from a network request into the object.
    /// - Parameters:
    ///   - data: The data received from the request.
    ///   - key: The key identifying the object to load.
    func decode(_ data: Data, key: Key) async throws -> Object
}

public extension SimpleNetworkLoader {
    func loadData(key: Key) async throws -> Object {
        let request = await createRequest(for: key)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try await self.decode(data, key: key)
    }
}

public extension SimpleNetworkLoader where Object: Codable {
    func decode(_ data: Data, key: Key) async throws -> Object {
        let handle = Task { () -> Object in
            let decoder = JSONDecoder()
            return try decoder.decode(Object.self, from: data)
        }
        return try await handle.value
    }
}
