import Foundation

/// A singleton collection used to store key-value pairs as a wrapper to `Cache`.
public protocol SharedCache: AnySharedCache {
    /// The shared `Cache`.
    static var shared: Cache<Key, Value> { get }
}

public extension SharedCache {
    /// Accesses the value associated with the given key for reading and writing. When you assign a value for a key and that key already exists, the cache overwrites the existing value. If the cache doesn’t contain the key, the key and value are added as a new key-value pair. If you assign `nil` as the value for the given key, the cache removes that key and its associated value.
    static subscript(key: Key) -> Value? {
        get {
            shared[key]
        }
        set {
            shared[key] = newValue
        }
    }
    
    /// Whether the value associated with the `key` is stale. Returns `true` if the key is not in the cache.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: Whether the value associated with the `key` is stale.
    static func isValueStale(_ key: Key) -> Bool {
        shared.isValueStale(forKey: key)
    }
}
