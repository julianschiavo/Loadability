# IdentifiableError

A uniquely identifiable error.

``` swift
public struct IdentifiableError: Error, Equatable, Identifiable
```

## Inheritance

`Equatable`, `Error`, `Identifiable`

## Initializers

### `init?(_:id:)`

Creates a new `IdentifiableError`.

``` swift
public init?(_ underlyingError: Error?, id: String? = nil)
```

#### Parameters

  - underlyingError: The underlying `Error`.
  - id: An optional identifier for the error.

## Properties

### `id`

A unique identifier for the error.

``` swift
var id: String
```

### `error`

The underlying error object.

``` swift
var error: Error
```

## Methods

### `==(lhs:rhs:)`

Checks whether two errors are the same

``` swift
public static func ==(lhs: IdentifiableError, rhs: IdentifiableError) -> Bool
```

#### Parameters

  - lhs: An error
  - rhs: Another error

#### Returns

Whether the errors are the same
