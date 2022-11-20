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
    @discardableResult func load(key: Key) async -> Object? {
        let task = Task { () -> Object in
            let object: Object
            
            let cached = await loadCachedData(key: key)
            if let cached = cached, !cache.isValueStale(key) {
                object = cached
            } else {
                object = try await loadData(key: key)
            }
            
            self.object = object
            await loadCompleted(key: key, object: object)
            return object
        }
        self.task = task
        
        do {
            let object = try await task.value
            self.task = nil
            return object
        } catch {
            catchError(error)
            return nil
        }
    }
    
    func refresh(key: Key) async {
        guard task == nil else { return }
        cancel()
        try? await cache.removeValue(for: key)
        object = nil
//        await load(key: key)
    }
    
    /// Attempts to load data from the cache.
    /// - Parameter key: The key identifying the object to load.
    private func loadCachedData(key: Key) async -> Object? {
        let handle = Task {
            try? await self.cache.value(for: key)
        }
        return await handle.value
    }
    
    /// Attempts to fetch data from the cache.
    /// - Parameters:
    ///   - key: The key identifying the object to load.
    ///   - completion: A completion handler called with the object, or `nil` if no object was found.
    func getCachedData(key: Key) async -> Object? {
        let handle = Task {
            try? await self.cache.value(for: key)
        }
        return await handle.value
    }
    
    func loadCompleted(key: Key, object: Object) async {
        Task {
            try? await self.cache.update(key: key, to: object)
        }
    }
}

public extension CachedLoader where Key == GenericKey {
    @discardableResult func load() async -> Object? {
        await load(key: .key)
    }
}
