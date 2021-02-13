# SimpleNetworkLoader

A type that can load data from over the network and throw errors.

``` swift
public protocol SimpleNetworkLoader: Loader
```

## Inheritance

[`Loader`](./Loader)

## Requirements

### createRequest(for:​)

Creates a `URLRequest` for a network loading request.

``` swift
func createRequest(for key: Key) -> URLRequest
```

#### Parameters

  - key: The key identifying the object to load.

### decode(\_:​key:​)

Decodes data received from a network request into the object.

``` swift
func decode(_ data: Data, key: Key) throws -> Object
```

#### Parameters

  - data: The data received from the request.
  - key: The key identifying the object to load.
