import SwiftUI

/// A view that loads content using a `Loader` before displaying the content in a custom `View`.
public struct Load<Loader: SomeLoader, Value, Content: View, PlaceholderContent: View>: View {
    
    /// The loader used to load content.
    @ObservedObject private var loader: Loader
    
    /// The key identifying the object to load.
    private let key: Loader.Key
    
    /// The key path of the value on the loaded object, defaults to `nil`.
    private var keyPath: KeyPath<Loader.Object, Value?>?
    
    /// Builds a view using a loaded object.
    private var contentBuilder: (Value) -> Content
    
    /// Builds a placeholder for the content.
    private var placeholderContentBuilder: () -> PlaceholderContent
    
    /// The loaded object, if loaded.
    private var value: Value? {
        guard let object = loader.object else { return nil }
        if let keyPath = keyPath {
            return object[keyPath: keyPath]
        } else {
            return object as? Value
        }
    }
    
    /// Whether an error alert is currently presented.
    @State private var isErrorAlertPresented = false
    
    public init(with loader: Loader,
         key: Loader.Key,
         objectKeyPath: KeyPath<Loader.Object, Value?>,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content,
         @ViewBuilder placeholder placeholderContentBuilder: @escaping () -> PlaceholderContent) {
        
        self.loader = loader
        self.key = key
        self.keyPath = objectKeyPath
        self.placeholderContentBuilder = placeholderContentBuilder
        self.contentBuilder = contentBuilder
    }
    
    public init<P: HasPlaceholder>(with loader: Loader,
                            key: Loader.Key,
                            objectKeyPath: KeyPath<Loader.Object, Value?>,
                            placeholderView: P.Type,
                            @ViewBuilder content contentBuilder: @escaping (Value) -> Content)
    where PlaceholderContent == P.Placeholder {
        
        self.loader = loader
        self.key = key
        self.keyPath = objectKeyPath
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            placeholderView.placeholder
        }
    }
    
    public var body: some View {
        bodyContent
            .task {
                await loader.load(key: key)
            }
            .onDisappear {
                loader.cancel()
            }
    }
    
    /// The content shown.
    @ViewBuilder private var bodyContent: some View {
        if let value = value {
            contentBuilder(value)
        } else {
            placeholderContent
        }
    }
    
    /// The placeholder shown while loading.
    private var placeholderContent: some View {
        placeholderContentBuilder()
    }
    
    /// Presents an alert to the user if an error occurs.
    /// - Parameters:
    ///   - alertContent: Content to display in the alert.
    public func displayingErrors(message: ((Error) -> String)? = nil) -> some View {
        var error: _LocalizedError?
        if let loaderError = loader.error {
            error = _LocalizedError(loaderError)
        }
        
        return alert(isPresented: $isErrorAlertPresented, error: error) { _ in
            Button("OK") {
                loader.dismissError()
            }
        } message: { error in
            Text(message?(error) ?? error.userVisibleTitle)
        }
    }
}

// No Key
public extension Load where Loader.Key == GenericKey {
    init(with loader: Loader,
         objectKeyPath: KeyPath<Loader.Object, Value?>,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content,
         @ViewBuilder placeholder placeholderContentBuilder: @escaping () -> PlaceholderContent) {
        
        self.loader = loader
        self.key = .key
        self.keyPath = objectKeyPath
        self.placeholderContentBuilder = placeholderContentBuilder
        self.contentBuilder = contentBuilder
    }
    
    init<P: HasPlaceholder>(with loader: Loader,
                            objectKeyPath: KeyPath<Loader.Object, Value?>,
                            placeholderView: P.Type,
                            @ViewBuilder content contentBuilder: @escaping (Value) -> Content) where PlaceholderContent == P.Placeholder {
        
        self.loader = loader
        self.key = .key
        self.keyPath = objectKeyPath
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            placeholderView.placeholder
        }
    }
}

// No Key, Activity Indicator
public extension Load where Loader.Key == GenericKey, PlaceholderContent == ProgressView<EmptyView, EmptyView> {
    init(with loader: Loader,
         objectKeyPath: KeyPath<Loader.Object, Value?>,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content) {
        
        self.loader = loader
        self.key = .key
        self.keyPath = objectKeyPath
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            ProgressView()
        }
    }
}

// No Key, Base Object
public extension Load where Loader.Key == GenericKey, Loader.Object == Value {
    init(with loader: Loader,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content,
         @ViewBuilder placeholder placeholderContentBuilder: @escaping () -> PlaceholderContent) {
        
        self.loader = loader
        self.key = .key
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = placeholderContentBuilder
    }
}

// No Key, Base Object, Activity Indicator
public extension Load where Loader.Key == GenericKey, Loader.Object == Value, PlaceholderContent == ProgressView<EmptyView, EmptyView> {
    init(with loader: Loader,
         content contentBuilder: @escaping (Value) -> Content) {
        
        self.loader = loader
        self.key = .key
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            ProgressView()
        }
    }
}

// Base Object
public extension Load where Value == Loader.Object {
    init(with loader: Loader,
         key: Loader.Key,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content,
         @ViewBuilder placeholder placeholderContentBuilder: @escaping () -> PlaceholderContent) {
        
        self.loader = loader
        self.key = key
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = placeholderContentBuilder
    }
    
    init<P: HasPlaceholder>(with loader: Loader,
                            key: Loader.Key,
                            placeholderView: P.Type,
                            @ViewBuilder content contentBuilder: @escaping (Value) -> Content) where PlaceholderContent == P.Placeholder {
        
        self.loader = loader
        self.key = key
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            placeholderView.placeholder
        }
    }
}

// Base Object, Activity Indicator
public extension Load where Value == Loader.Object, PlaceholderContent == ProgressView<EmptyView, EmptyView> {
    init(with loader: Loader,
         key: Loader.Key,
         content contentBuilder: @escaping (Value) -> Content) {
        
        self.loader = loader
        self.key = key
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            ProgressView()
        }
    }
}

// Activity Indicator
public extension Load where PlaceholderContent == ProgressView<EmptyView, EmptyView> {
    init(with loader: Loader,
         key: Loader.Key,
         objectKeyPath: KeyPath<Loader.Object, Value?>,
         @ViewBuilder content contentBuilder: @escaping (Value) -> Content) {
        
        self.loader = loader
        self.key = key
        self.keyPath = objectKeyPath
        self.contentBuilder = contentBuilder
        self.placeholderContentBuilder = {
            ProgressView()
        }
    }
}
