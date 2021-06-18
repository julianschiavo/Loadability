import Foundation

/// A mutable collection, with support for serialization and storage, used to store key-value pairs that are subject to eviction when resources are low.
public final class SerializableCache<Key: Codable & Hashable & Identifiable, Value: Codable>: Cache<Key, Value>, Codable {
    /// The unique name for the cache.
    final var name: String
    
    /// The folder in which to store the cache.
    final var folderURL: URL
    
    /// A ledger of keys stored in the cache, used when serializing data to disk.
    private final let keyLedger = KeyLedger()
    
    /// Creates a new `SerializableCache`.
    /// - Parameters:
    ///   - name: The unique name for the cache.
    ///   - autoRemoveStaleItems: Whether to automatically remove stale items, defaults to `false`.
    /// - Parameter itemLifetime: How many milliseconds items are valid for, defaults to 3600. This is not used if `autoRemoveStaleItems` is equal to `false`.
    ///   - folderURL: The folder in which to store the cache, defaults to the system cache directory.
    private init(
        name: String,
        shouldAutomaticallyRemoveStaleItems autoRemoveStaleItems: Bool = false,
        itemLifetime: TimeInterval = 3600,
        folderURL: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    ) {
        
        guard let folderURL = folderURL else {
            fatalError("Invalid Folder URL")
        }
        
        self.name = name
        self.folderURL = folderURL
        super.init(shouldAutomaticallyRemoveStaleItems: autoRemoveStaleItems, itemLifetime: itemLifetime)
        
        _cache.delegate = keyLedger
    }
    
    /// Decodes an encoded `SerializableCache`.
    /// - Parameter decoder: The decoder.
    /// - Throws: When there is an error in decoding.
    public required convenience init(from decoder: Decoder) throws {
        self.init(name: "")
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([_Entry].self)
        entries.forEach { updateValue($0.value, forKey: $0.key, expirationDate: $0.expirationDate) }
    }
    
    // MARK: - Codable
    
    /// Encodes the cache and key-value pairs to disk.
    /// - Parameter encoder: The encoder.
    /// - Throws: When there is an error in encoding.
    public final func encode(to encoder: Encoder) throws {
        let entries = keyLedger.keys.compactMap(entry)
        var container = encoder.singleValueContainer()
        try container.encode(entries)
    }
    
    /// Encodes and saves the cache to disk.
    public final func save() {
        guard !name.isEmpty else { return }
        let fileURL = folderURL.appendingPathComponent(self.name + ".cache")
        
        DispatchQueue.global(qos: .default).async {
            do {
                let data = try JSONEncoder().encode(self)
                try data.write(to: fileURL)
            } catch {
                print("[Cache] Failed to save.",
                      error.localizedDescription,
                      (error as NSError).localizedRecoverySuggestion ?? "")
            }
        }
    }
    
    /// Loads a previously-serialized cache from disk.
    /// - Parameters:
    ///   - name: The unique name of the cache.
    ///   - shouldAutomaticallyRemoveStaleItems: Whether to automatically remove stale items, defaults to `false`.
    ///   - folderURL: The folder in which to store the cache, defaults to the system cache directory.
    /// - Returns: The loaded cache.
    public static func load(
        name: String,
        shouldAutomaticallyRemoveStaleItems: Bool = false,
        folderURL: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    ) -> SerializableCache<Key, Value> {
        
        guard let folderURL = folderURL else {
            fatalError("Invalid Folder URL")
        }
        
        do {
            let fileURL = folderURL.appendingPathComponent(name + ".cache")
            let data = try Data(contentsOf: fileURL)
            let cache = try JSONDecoder().decode(self, from: data)
            cache.name = name // Setting after decoding avoids re-saving cache to disk unnescessarily
            return cache
        } catch {
            print("[Cache] Failed to load (Name: \(name)).",
                  error.localizedDescription,
                  (error as NSError).localizedRecoverySuggestion ?? "")
            
            let empty = SerializableCache(name: name, shouldAutomaticallyRemoveStaleItems: shouldAutomaticallyRemoveStaleItems)
            return empty
        }
    }
    
    // MARK: - Internal
    
    /// Updates the cached entry for the given key, or adds the entry to the cache if the key does not exist.
    /// - Parameters:
    ///   - entry: The entry to add to the cache.
    ///   - key: The key to associate with `entry`. If `key` already exists in the cache, `entry` replaces the existing entry. If `key` isn’t already a key of the cache, the entry is added.
    override final func updateEntry(_ entry: _Entry, forKey key: _Key) {
        _cache.setObject(entry, forKey: key)
        keyLedger.insert(entry.key, to: self)
    }
    
    /// Removes the given key and its associated value from the cache.
    /// - Parameter key: The key to remove along with its associated value.
    override final func removeValue(forKey key: Key) {
        _cache.removeObject(forKey: _Key(key))
        keyLedger.remove(key, from: self)
    }
    
    /// A ledger that stores a list of keys, conforming to `NSCacheDelegate` to automatically remove evicted keys.
    final class KeyLedger: NSObject, NSCacheDelegate {
        /// The list of keys.
        private(set) final var keys = Set<Key>()
        
        final func insert(_ key: Key, to cache: SerializableCache<Key, Value>) {
            guard keys.insert(key).inserted else { return }
            cache.save()
        }
        
        final func remove(_ key: Key, from cache: SerializableCache<Key, Value>) {
            keys.remove(key)
            cache.save()
        }
        
        final func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? _Entry else { return }
            keys.remove(entry.key)
        }
    }
}
