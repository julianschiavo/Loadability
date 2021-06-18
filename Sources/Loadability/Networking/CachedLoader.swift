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
        task = async {
            let object: Object
            
            let cached = await loadCachedData(key: key)
            if let cached = cached, !cache.isValueStale(key) {
                object = cached
            } else {
                object = try await loadData(key: key)
            }
            
            self.object = object
            await loadCompleted(key: key, object: object)
        }
        do {
            try await task?.get()
        } catch {
            catchError(error)
        }
    }
    
    func refresh(key: Key) async {
        guard task == nil else { return }
        cancel()
        cache[key] = nil
        object = nil
//        await load(key: key)
    }
    
    /// Attempts to load data from the cache.
    /// - Parameter key: The key identifying the object to load.
    private func loadCachedData(key: Key) async -> Object? {
        let handle = async {
            self.cache[key]
        }
        return await handle.get()
    }
    
    /// Attempts to fetch data from the cache.
    /// - Parameters:
    ///   - key: The key identifying the object to load.
    ///   - completion: A completion handler called with the object, or `nil` if no object was found.
    func getCachedData(key: Key) async -> Object? {
        let handle = async {
            self.cache[key]
        }
        return await handle.get()
    }
    
    func loadCompleted(key: Key, object: Object) async {
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
