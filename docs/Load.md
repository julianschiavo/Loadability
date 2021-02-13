# Load

A view that loads content using a `Loader` before displaying the content in a custom `View`.

``` swift
public struct Load<Loader: SomeLoader, Value, Content: View, PlaceholderContent: View>: View
```

## Inheritance

`View`

## Initializers

### `init(with:key:objectKeyPath:content:placeholder:)`

``` swift
public init(with loader: Loader, key: Loader.Key, objectKeyPath: KeyPath<Loader.Object, Value?>, content contentBuilder: @escaping (Value) -> Content, placeholder placeholderContentBuilder: @escaping () -> PlaceholderContent)
```

### `init(with:key:objectKeyPath:placeholderView:content:)`

``` swift
public init<P: HasPlaceholder>(with loader: Loader, key: Loader.Key, objectKeyPath: KeyPath<Loader.Object, Value?>, placeholderView: P.Type, content contentBuilder: @escaping (Value) -> Content) where PlaceholderContent == P.Placeholder
```

## Properties

### `body`

``` swift
var body: some View
```
