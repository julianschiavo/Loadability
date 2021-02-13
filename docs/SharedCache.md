# SharedCache

A singleton collection used to store key-value pairs as a wrapper to `Cache`.

``` swift
public protocol SharedCache: AnySharedCache
```

## Inheritance

[`AnySharedCache`](./AnySharedCache)

## Requirements

### shared

The shared `Cache`.

``` swift
var shared: Cache<Key, Value>
```
