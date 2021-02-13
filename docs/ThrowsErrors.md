# ThrowsErrors

A type that can throw errors that should be shown to the user.

``` swift
public protocol ThrowsErrors
```

## Requirements

### error

An error, if one occurred. Must be annotated with a publisher property wrapper, such as `@State` or `@Published`, to work.

``` swift
var error: IdentifiableError?
```
