import SwiftUI

/// A `View` that loads content through a `Loader`.
public protocol LoadableView: View {
    /// The type of `View` representing the content view.
    associatedtype Content: View
    /// The type of loader.
    associatedtype Loader: SomeLoader
    /// The type of `View` representing the placeholder view.
    associatedtype Placeholder: View
    /// The type of value loaded by the `Loader`.
    associatedtype Value
    
    /// The type of `Load` view.
    typealias LoaderView = Load<Loader, Value, Content, Placeholder>?
    
    /// The key path of the value on the loaded object.
    typealias ValueKeyPath = KeyPath<Loader.Object, Value?>
    
    /// The key identifying the object to load.
    var key: Loader.Key { get }
    
    /// The key path of the value on the loaded object, defaults to `nil`.
    var keyPath: ValueKeyPath? { get }
    
    /// The loader used to load content.
    var loader: Loader { get }
    
    /// The placeholder to show while loading.
    func placeholder() -> Placeholder
    
    /// Creates a view using loaded content.
    /// - Parameter value: Loaded content.
    func body(with value: Value) -> Content
}

public extension LoadableView {
    var keyPath: KeyPath<Loader.Object, Value?>? {
        nil
    }
    
    /// The `Load` wrapper used to handle the view state.
    @ViewBuilder var loaderView: LoaderView {
        if let keyPath = keyPath {
            Load(with: loader, key: key, objectKeyPath: keyPath, content: body, placeholder: placeholder)
        }
    }
}

public extension LoadableView where Loader.Key == GenericKey {
    var key: GenericKey {
        .key
    }
    
    /// The `Load` wrapper used to handle the view state.
    @ViewBuilder var loaderView: LoaderView {
        if let keyPath = keyPath {
            Load(with: loader, objectKeyPath: keyPath, content: body, placeholder: placeholder)
        }
    }
}

public extension LoadableView where Loader.Key == GenericKey, Loader.Object == Value {
    /// The `Load` wrapper used to handle the view state.
    @ViewBuilder var loaderView: LoaderView {
        Load(with: loader, content: body, placeholder: placeholder)
    }
}

public extension LoadableView where Loader.Object == Value {
    /// The `Load` wrapper used to handle the view state.
    @ViewBuilder var loaderView: LoaderView {
        Load(with: loader, key: key, content: body, placeholder: placeholder)
    }
}
