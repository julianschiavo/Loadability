import Foundation

/// A mutable collection used to store key-value pairs that are subject to eviction when resources are low.
public class Cache<Key: Hashable & Identifiable, Value> {
    
    /// Whether the cache automatically removes stale items.
    final let autoRemoveStaleItems: Bool
    
    /// How many milliseconds items are valid for, defaults to 3600. This is not used if `autoRemoveStaleItems` is equal to `false`.
    final let itemLifetime: TimeInterval
    
    /// The wrapped `NSCache`.
    final let _cache = NSCache<_Key, _Entry>()
    
    // MARK: - Public
    
    /// Creates a new `Cache`
    /// - Parameter autoRemoveStaleItems: Whether to automatically remove stale items, `false` by default.
    /// - Parameter itemLifetime: How many milliseconds items are valid for, defaults to 3600. This is not used if `autoRemoveStaleItems` is equal to `false`.
    public init(shouldAutomaticallyRemoveStaleItems autoRemoveStaleItems: Bool = false, itemLifetime: TimeInterval = 3600) {
        self.autoRemoveStaleItems = autoRemoveStaleItems
        self.itemLifetime = itemLifetime
    }
    
    /// Accesses the value associated with the given key for reading and writing. When you assign a value for a key and that key already exists, the cache overwrites the existing value. If the cache doesn’t contain the key, the key and value are added as a new key-value pair. If you assign `nil` as the value for the given key, the cache removes that key and its associated value.
    public final subscript(key: Key) -> Value? {
        get {
            value(for: key)
        }
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            
            updateValue(value, forKey: key)
        }
    }
    
    /// Whether the value associated with the `key` is stale. Returns `true` if the key is not in the cache.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: Whether the value associated with the `key` is stale.
    final func isValueStale(forKey key: Key) -> Bool {
        guard let value = entry(for: key) else {
            return true
        }
        
        return Date() > value.expirationDate
    }
    
    // MARK: - Internal
    
    /// Accesses the value associated with the given key.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: The value associated with `key` if `key` is in the cache; otherwise, `nil`.
    final func value(for key: Key) -> Value? {
        entry(for: key)?.value
    }
    
    /// Accesses the entry associated with the given key.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: The entry associated with `key` if `key` is in the cache; otherwise, `nil`.
    final func entry(for key: Key) -> _Entry? {
        let key = _Key(key)
        return entry(for: key)
    }
    
    /// Accesses the entry associated with the given key.
    /// - Parameter key: The key to find in the cache.
    /// - Returns: The entry associated with `key` if `key` is in the cache; otherwise, `nil`.
    private final func entry(for key: _Key) -> _Entry? {
        _cache.object(forKey: key)
    }
    
    /// Updates the cached value for the given key, or adds the key-value pair to the cache if the key does not exist.
    /// - Parameters:
    ///   - value: The new value to add to the cache.
    ///   - key: The key to associate with `value`. If `key` already exists in the cache, `value` replaces the existing associated value. If `key` isn’t already a key of the cache, the (`key`, `value`) pair is added.
    ///   - expirationDate: The date at which the entry will become stale, and be reloaded.
    final func updateValue(_ value: Value, forKey key: Key, expirationDate suggestedExpirationDate: Date? = nil) {
        let expirationDate = suggestedExpirationDate ?? Date().addingTimeInterval(itemLifetime)
        let _key = _Key(key)
        let entry = _Entry(key: key, value: value, expirationDate: expirationDate)
        updateEntry(entry, forKey: _key)
    }
    
    /// Updates the cached entry for the given key, or adds the entry to the cache if the key does not exist.
    /// - Parameters:
    ///   - entry: The entry to add to the cache.
    ///   - key: The key to associate with `entry`. If `key` already exists in the cache, `entry` replaces the existing entry. If `key` isn’t already a key of the cache, the entry is added.
    func updateEntry(_ entry: _Entry, forKey key: _Key) {
        _cache.setObject(entry, forKey: key)
    }
    
    /// Removes the given key and its associated value from the cache.
    /// - Parameter key: The key to remove along with its associated value.
    func removeValue(forKey key: Key) {
        let key = _Key(key)
        _cache.removeObject(forKey: key)
    }
    
    /// Removes the given key and its associated value from the cache.
    /// - Parameter key: The key to remove along with its associated value.
//    private final func removeValue(forKey key: _Key) {
//        
//    }
    
    /// Empties the cache.
    private final func removeAll() {
        _cache.removeAllObjects()
    }
    
    // MARK: - Wrapped Classes
    
    /// A wrapper for a `Key`
    final class _Key: NSObject {
        /// The wrapped `Key`
        let key: Key.ID
        
        /// Creates a new wrapper for a key.
        /// - Parameter key: The key to wrap
        init(_ key: Key) {
            self.key = key.id
        }
        
        override var hash: Int {
            key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? Self else { return false }
            return value.key == key
        }
    }
    
    /// A wrapper for a key-value pair.
    final class _Entry {
        /// The key
        let key: Key
        
        /// The value
        let value: Value
        
        /// The expiration date of the object
        let expirationDate: Date
        
        /// Creates a new wrapper for a key-value pair.
        /// - Parameters:
        ///   - key: The key
        ///   - value: The value
        ///   - expirationDate: The expiration date, at which point the data will be reloaded
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

extension Cache._Entry: Codable where Key: Codable, Value: Codable {}
