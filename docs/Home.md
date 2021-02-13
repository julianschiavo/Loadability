# Types

  - [Cache](./Cache):
    A mutable collection used to store key-value pairs that are subject to eviction when resources are low.
  - [SerializableCache](./SerializableCache):
    A mutable collection, with support for serialization and storage, used to store key-value pairs that are subject to eviction when resources are low.
  - [GenericKey](./GenericKey):
    A generic key, used when the loadable value is not keyed by anything.
  - [IdentifiableError](./IdentifiableError):
    A uniquely identifiable error.
  - [Load](./Load):
    A view that loads content using a `Loader` before displaying the content in a custom `View`.

# Protocols

  - [AnySharedCache](./AnySharedCache):
    A shared cache.
  - [SharedCache](./SharedCache):
    A singleton collection used to store key-value pairs as a wrapper to `Cache`.
  - [SharedSerializableCache](./SharedSerializableCache):
    A singleton collection, with support for serialization and storage, used to store key-value pairs as a wrapper to `SerializableCache`.
  - [CachedLoader](./CachedLoader):
    A type that can load data from a source with caching.
  - [Loader](./Loader):
    A type that can load data from a source and throw errors.
  - [SimpleNetworkLoader](./SimpleNetworkLoader):
    A type that can load data from over the network and throw errors.
  - [HasPlaceholder](./HasPlaceholder):
    A view that has a placeholder
  - [ThrowsErrors](./ThrowsErrors):
    A type that can throw errors that should be shown to the user.
  - [LoadableView](./LoadableView):
    A `View` that loads content through a `Loader`.

# Global Typealiases

  - [SomeLoader](./SomeLoader)
  - [AnyIdentifiableError](./AnyIdentifiableError)
