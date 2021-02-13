# Loader

A type that can load data from a source and throw errors.

``` swift
public protocol Loader: ObservableObject, ThrowsErrors
```

## Inheritance

`ObservableObject`, [`ThrowsErrors`](./ThrowsErrors)

## Requirements

### object

A publisher for the object that is loaded.

``` swift
var object: Object?
```

### cancellable

An ongoing request.

``` swift
var cancellable: AnyCancellable?
```

### load(key:​)

Begins loading the object.

``` swift
func load(key: Key)
```

#### Parameters

  - key: The key identifying the object to load.

### createPublisher(key:​)

Creates a publisher that loads the object.

``` swift
func createPublisher(key: Key) -> AnyPublisher<Object, Error>?
```

#### Parameters

  - key: The key identifying the object to load.

### loadData(key:​)

Starts loading the object's data.

``` swift
func loadData(key: Key)
```

#### Parameters

  - key: The key identifying the object to load.

### loadCompleted(key:​object:​)

Called when the object has been loaded successfully.

``` swift
func loadCompleted(key: Key, object: Object)
```

#### Parameters

  - key: The key identifying the object that was loaded.
  - object: The loaded object.

### cancel()

``` swift
func cancel()
```
