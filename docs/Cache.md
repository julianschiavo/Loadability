# Cache

A mutable collection used to store key-value pairs that are subject to eviction when resources are low.

``` swift
public class Cache<Key: Hashable & Identifiable, Value>
```

## Initializers

### `init(shouldAutomaticallyRemoveStaleItems:)`

Creates a new `Cache`

``` swift
public init(shouldAutomaticallyRemoveStaleItems autoRemoveStaleItems: Bool = false)
```

#### Parameters

  - autoRemoveStaleItems: Whether to automatically remove stale items, `false` by default.
