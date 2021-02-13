# SharedSerializableCache

A singleton collection, with support for serialization and storage, used to store key-value pairs as a wrapper to `SerializableCache`.

``` swift
public protocol SharedSerializableCache: AnySharedCache
```

## Inheritance

[`AnySharedCache`](./AnySharedCache)

## Requirements

### shared

The shared `SerializableCache`.

``` swift
var shared: SerializableCache<Key, Value>
```
