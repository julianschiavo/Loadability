import Foundation

/// A singleton collection used to store key-value pairs as a wrapper to `Cache`.
public protocol SharedCache: AnySharedCache {
    /// The shared `Cache`.
    static var shared: Cache<Key, Value> { get }
}

public extension SharedCache {
    /// Accesses the value associated with the given key.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: The value associated with `key` if `key` is in the cache; otherwise, `nil`.
    static func value(for key: Key) async -> Value? {
        shared[key]
    }
    
    /// Updates the cached value for the given key, or adds the key-value pair to the cache if the key does not exist.
    /// - Parameters:
    ///   - value: The new value to add to the cache.
    ///   - key: The key to associate with `value`. If `key` already exists in the cache, `value` replaces the existing associated value. If `key` isn’t already a key of the cache, the (`key`, `value`) pair is added.
    static func update(key: Key, to newValue: Value) async {
        shared[key] = newValue
    }
    
    /// Removes the given key and its associated value from the cache.
    /// - Parameter key: The key to remove along with its associated value.
    static func removeValue(for key: Key) async {
        shared[key] = nil
    }
    
    /// Whether the value associated with the `key` is stale. Returns `true` if the key is not in the cache.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: Whether the value associated with the `key` is stale.
    static func isValueStale(_ key: Key) -> Bool {
        shared.isValueStale(forKey: key)
    }
}
