import Foundation

/// A type that can load data from a source with caching.
@MainActor
public protocol CachedLoader: Loader where Key == Cache.Key, Object == Cache.Value {
    /// The type of cache.
    associatedtype Cache: AnySharedCache
    
    /// The cache.
    var cache: Cache.Type { get }
}

public extension CachedLoader {
    func load(key: Key) async {
        loadCachedData(key: key)
        if cache.isValueStale(key) {
            await loadData(key: key)
        }
    }
    
    /// Attempts to load data from the cache.
    /// - Parameter key: The key identifying the object to load.
    private func loadCachedData(key: Key) {
        guard let object = self.cache[key] else { return }
        DispatchQueue.main.async {
            self.object = object
        }
    }
    
    /// Attempts to fetch data from the cache.
    /// - Parameters:
    ///   - key: The key identifying the object to load.
    ///   - completion: A completion handler called with the object, or `nil` if no object was found.
    func getCachedData(key: Key, completion: @escaping (Object?) -> Void) {
        completion(self.cache[key])
    }
    
    @available(iOS 15.0, watchOS 15.0, macOS 15.0, *)
    func loadCompleted(key: Key, object: Object) {
        async {
            self.cache[key] = object
        }
    }
}

public extension CachedLoader where Key == GenericKey {
    func load() async {
        await load(key: .key)
    }
}
