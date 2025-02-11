# 📩 Loadability
### Powerful, modern networking and caching with SwiftUI support
#### v1.0.6

**This package has changed since the documentation was updated to add support for newer language features (async/await). To support older versions of operating systems, see the [deprecated branch](https://github.com/julianschiavo/Loadability/tree/deprecated).**

<br>

**Loadability** is an advanced networking and caching library for Swift that allows you to effortlessly implement a custom networking and/or caching stack in your app, with native support for `Combine` and `SwiftUI`.

Loadability uses Apple's `Combine` framework to publish loaded objects and errors, and has built-in `SwiftUI` support to create views that load content and display placeholders while loading. 

## Requirements

**Loadability** supports **iOS 14+**, **macOS 11+**, and **watchOS 7+**. It does not have any dependencies.

## Installation

You can use **Loadability** as a Swift Package, or add it manually to your project. 

### Swift Package Manager (SPM)

Swift Package Manager is a way to add dependencies to your app, and is natively integrated with Xcode.

To add **Loadability** with SPM, click `File` ► `Swift Packages` ► `Add Package Dependency...`, then type in the URL to this Github repo. Xcode will then add the package to your project and perform all the necessary work to build it.

```
https://github.com/julianschiavo/Loadability
```

Alternatively, add the package to your `Package.swift` file.

```swift
let package = Package(
    // ...
    dependencies: [
        .package(url: "https://github.com/julianschiavo/Loadability.git", from: "1.0.0")
    ],
    // ...
)
```

*See [SPM documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation) to learn more.*

### Manually

If you prefer not to use SPM, you can also add **Loadability** as a normal framework by building the library from this repository. (See other sources for instructions on doing this.)

## Usage

Loadability declares basic protocols and classes that you extend in your app to build loaders and caches. It also has an (optional) `SwiftUI` integration (see [below](#swiftui-integration)) for views to load their data and show placeholders while loading.

The library has [extensive documentation](https://julianschiavo.github.io/Loadability/). If you are looking to gain an advanced understanding of the library, or to implement something not discussed below, please consult the inline documentation before filing an issue.

*Note that the code snippets in this section have some code omitted for brevity; see the [Examples](#examples) section for complete code examples.*

### Networking

Loadability networking in centered around the concept of loaders. A `Loader` loads data from some source and publishes it as an `ObservableObject`, which you can observe manually or integrate through the [`SwiftUI` support](#swiftui-integration).

To create a loader, you can create a class that conforms to the abstract `Loader` protocol, or conform to one of the sub-protocols that implement default behaviour, such as `SimpleNetworkLoader` and `CachedLoader`.

Loaders have some minimal shared requirements, including published properties for the object and a possible error while loading, and methods that load the data. You can extend loaders to conform to your own custom requirements.

This is an example of a loader. Each loader has an associated type for the object type that is loaded, and the key that is used by the loader to identify the object to load.
```swift
class YourLoader: Loader {
    @Published var object: YourObject?
    @Published var error: IdentifiableError?

    func createRequest(for key: YourKey) -> URLRequest {
        URLRequest(url: /* some URL */)
    }

    func createPublisher(key: YourKey) -> AnyPublisher<YourObject, Error>? {
        let request = createRequest(for: key)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .retry(3)
            .tryMap { data, response in
                try self.decode(data, key: key)
            }
            .eraseToAnyPublisher()
    }
    
    private func decode(_ data: Data, key: YourKey) throws -> YourObject {
        /* decode the data, for example, using a JSONDecoder */
    }
}
```

As noted previously, loaders automatically conform to `ObservableObject`; you can observe the published properties yourself or use the [SwiftUI integration](#swiftui-integration).

#### Specific Loaders

Loadability has a few specific built-in loaders that implement common requirements, reducing the code required for some implementations. You can subclass a specific built-in loader instead of the general `Loader` protocol if it meets your needs.

##### `SimpleNetworkLoader`

`SimpleNetworkLoader` implements a basic networking loader, with optional predefined `Codable` decoding support. You can use this loader for instances where you want a default network loader.

An example of this loader is shown here; as you can see, it is simpler to implement than a full `Loader` subclass, handling the networking code for you using only a `URLRequest` you create. You can create a custom decoding implementation to decode the `Data` received from the network request, or, if your object type conforms to `Codable`, take advantage of the predefined decoding implementation which uses a `JSONDecoder`.
```swift
class YourLoader: SimpleNetworkLoader {
    @Published var object: YourObject?
    @Published var error: IdentifiableError?

    func createRequest(for key: YourKey) -> URLRequest {
        URLRequest(url: /* some URL */)
    }
    
    func decode(_ data: Data, key: YourKey) throws -> YourObject {
        /* optional custom decoding implementation */
    }
}
```

##### `CachedLoader`

`CachedLoader` uses the caching system discussed below to implement a loader that caches loaded data. You are encouraged to use this loader when you want to cache your data instead of implementing your own caching loader, as it handles tasks such as pre-loading cached data and updating the cache asynchronously after loads.

This is an example of a `CachedLoader` subclass (see the [Caching](#caching) section to learn how to create a `Cache`).
```swift
class YourLoader: CachedLoader {
    @Published var object: YourObject?
    @Published var error: IdentifiableError?

    var cache = YourCache.self /* a SharedCache or SharedSerializableCache type */
    
    func createRequest(for key: YourKey) -> URLRequest {
        URLRequest(url: /* some URL */)
    }

    func createPublisher(key: YourKey) -> AnyPublisher<YourObject, Error>? {
        /* see the Loader example above */
    }

    private func decode(_ data: Data, key: YourKey) throws -> YourObject {
        /* see the Loader example above */
    }
}
```
The code is similar to the `Loader` snippet, as the caching is handled for you internally by the library; you simply need to provide a `Cache` which will be used.

### Caching

In addition to networking, Loadability has support for caching as a Swift implementation built on top of Apple's `NSCache` with a number of additional features including support for serialization (saving caches to disk for reuse).

The basic  `Cache` class is a basic wrapper for `NSCache`, supporting the same features as the Objective-C version. Create an instance of `Cache`, and use subscripts to access, modify, or delete values, as such:

```swift
let cache = Cache<YourKey, YourObject>()
cache[key] = YourObject() // Add value
cache[key] = YourObject(someParameter: true) // Modify value
let object = cache[key] // YourObject?, Access cached value
cache[key] = nil // Remove value
```

`SerializableCache` subclasses the base `Cache` class to add support for saving caches to disk, which allows you to reload an old cache on app restart or similar events. Each `SerializableCache` has a name, which must be unique per-app and the same on each initialization to identify the cache on disk. Note that the key and object types of serializable caches must conform to `Codable`.

Instead of creating an instance directly, you use the class method `load(name:)`, which attempts to load an existing cache from disk, falling back to creating a new cache if an existing one is not valid or does not exist, such as on the first initialization. Future calls of the method (such as on subsequent app restarts) load and decode the previously saved cache from disk.

```swift
let sCache = SerializableCache<YourKey, YourObject>.load(name: "Name")
```

The cache values are accessed, modified, and deleted in the same way as with the normal `Cache`. The `save()` method encodes and writes the cache to disk; this is called automatically on writes and modifications, so it is not necessary to call this yourself in normal implementations.

#### Shared Caches

Creating new cache instances, especially of `SerializableCache`, is costly and energy intensive. Additionally, creating multiple cache instances will result in cached data not being shared around your app, causing unnecessary network requests. 

Loadability has support for "shared" caches, which are a singleton-like pattern that allows you to use the same cache throughout your app for each type of cache you have. 

You create a shared cache by subclassing either `SharedCache` or `SharedSerializableCache`, depending on what features you want.

```swift
struct YourCache: SharedSerializableCache {
    typealias Key = YourKey
    typealias Value = YourValue
    static let shared = SerializableCache<YourKey, YourObject>.load(name: "Name")
}
```

Instead of creating multiple cache instances, use the `shared` instance every time you need that cache.

#### Using Caches with Loaders

As discussed above in the [CachedLoader](#cachedloader) section under Loaders, Loadability has an integration between caches and loaders. Although you can use cache instances directly with custom loaders, it is *strongly* recommended to use a shared cache and `CachedLoader`, as loaders are, by definition, created for each object that is loaded.

Create a shared cache following the code in the previous section on shared caches, and set the `cache` variable in your loader to the class's type (e.g. `YourCache.self`).

### SwiftUI Integration

Loadability has native support for SwiftUI; loading data in views is made extremely simple. After creating any type of Loader, make your views loadable by conforming to `LoadableView`. The protocol handles loading the data and displays your placeholder content while loading, then passes a `non-nil` object to a new `body(with:)` method you implement to create your body content.

You only need to implement some basic requirements; creating a loader type, passing the key, and implementing the placeholder and body methods. 

The following shows an example of creating a loadable view. Note a few key points:
- You must ensure that your loader variable is annotated by `@StateObject` or the loader's publisher will *not* update the view as expected 
- Because of Swift's behaviour with protocol conformance, your views must implement the `body` variable directly, passing in the `loaderView` generated by `LoadableView`

```swift
struct YourView: View, LoadableView {
    @StateObject var loader = YourLoader() // must be annotated by @StateObject

    var body: some View {
        loaderView // required
    }

    func body(with object: YourObject) -> some View {
        /* create a body with the object */
    }

    func placeholder() -> some View {
        ProgressView("Loading...")
    }
}
```

Loadability also exposes `Load`, which is a view type used internally by `LoadableView`. If you require a custom implementation, use this view to gain more control over the loading behaviour. However, try `LoadableView` first.

## Examples

The [Loadability Examples](https://github.com/julianschiavo/loadability-examples) repository contains real-world app examples demonstrating how to use the library. The `COVID-19` app project shows an implementation of Loadability with support for caching, and uses the cached and network loaders discussed above.

## Contributing

Contributions and pull requests are welcomed by anyone! If you find an issue with **Loadability**, file a Github Issue, or, if you know how to fix it, submit a pull request. 

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) and [Contribution Guidelines](CONTRIBUTING.md) before making a contribution.

## Credits & Sponsoring

**Loadability** was originally created by [Julian Schiavo](https://twitter.com/julianschiavo) in his spare time, and made available under the [MIT License](LICENSE). If you find the library useful, please consider [sponsoring me on Github](https://github.com/sponsors/julianschiavo), which contributes to development and learning resources, and allows me to keep making cool stuff like this!

Loadability is inspired by (and uses code by permission) from John Sundell's in depth blog posts on [Handling loading states within SwiftUI views](https://www.swiftbysundell.com/articles/handling-loading-states-in-swiftui/) and [Caching in Swift](https://swiftbysundell.com/articles/caching-in-swift/), so thank you to John for the inspiration and examples. If you want to gain a better understanding of loading or caching in Swift, I strongly recommend you check out the articles linked above, in addition to his many other articles!

## License

Available under the MIT License. See the [License](LICENSE) for more info.
