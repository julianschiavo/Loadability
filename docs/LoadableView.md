# LoadableView

A `View` that loads content through a `Loader`.

``` swift
public protocol LoadableView: View
```

## Inheritance

`View`

## Requirements

### key

The key identifying the object to load.

``` swift
var key: Loader.Key
```

### keyPath

The key path of the value on the loaded object, defaults to `nil`.

``` swift
var keyPath: ValueKeyPath?
```

### loader

The loader used to load content.

``` swift
var loader: Loader
```

### placeholder()

The placeholder to show while loading.

``` swift
func placeholder() -> Placeholder
```

### body(with:​)

Creates a view using loaded content.

``` swift
func body(with value: Value) -> Content
```

#### Parameters

  - value: Loaded content.
