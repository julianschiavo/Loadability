# SerializableCache

A mutable collection, with support for serialization and storage, used to store key-value pairs that are subject to eviction when resources are low.

``` swift
public final class SerializableCache<Key: Codable & Hashable & Identifiable, Value: Codable>: Cache<Key, Value>, Codable
```

## Inheritance

`Cache<Key, Value>`, `Codable`

## Initializers

### `init(from:)`

Decodes an encoded `SerializableCache`.

``` swift
public required convenience init(from decoder: Decoder) throws
```

#### Parameters

  - decoder: The decoder.

#### Throws

When there is an error in decoding.

## Methods

### `encode(to:)`

Encodes the cache and key-value pairs to disk.

``` swift
public final func encode(to encoder: Encoder) throws
```

#### Parameters

  - encoder: The encoder.

#### Throws

When there is an error in encoding.

### `save()`

Encodes and saves the cache to disk.

``` swift
public final func save()
```

### `load(name:shouldAutomaticallyRemoveStaleItems:folderURL:)`

Loads a previously-serialized cache from disk.

``` swift
public static func load(name: String, shouldAutomaticallyRemoveStaleItems: Bool = false, folderURL: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first) -> SerializableCache<Key, Value>
```

#### Parameters

  - name: The unique name of the cache.
  - shouldAutomaticallyRemoveStaleItems: Whether to automatically remove stale items, defaults to `false`.
  - folderURL: The folder in which to store the cache, defaults to the system cache directory.

#### Returns

The loaded cache.
