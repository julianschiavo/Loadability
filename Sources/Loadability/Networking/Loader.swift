import Combine
import Foundation

public typealias SomeLoader = Loader

/// A type that can load data from a source and throw errors.
@MainActor
public protocol Loader: ObservableObject, ThrowsErrors {
    /// The type of key that identifies objects.
    associatedtype Key: Hashable
    /// The type of object to load.
    associatedtype Object
    
    /// Creates a new instance of the loader.
    init()
    
    /// A publisher for the object that is loaded.
    var object: Object? { get set }
    
    /// An ongoing request.
    var cancellable: AnyCancellable? { get set }
    
    /// Begins loading the object.
    /// - Parameter key: The key identifying the object to load.
    func load(key: Key) async
    
    /// Creates a publisher that loads the object.
    /// - Parameter key: The key identifying the object to load.
    func createPublisher(key: Key) -> AnyPublisher<Object, Error>?
    
    /// Starts loading the object's data.
    /// - Parameter key: The key identifying the object to load.
    func loadData(key: Key) async
    
    /// Called when the object has been loaded successfully.
    /// - Parameters:
    ///   - key: The key identifying the object that was loaded.
    ///   - object: The loaded object.
    func loadCompleted(key: Key, object: Object)
    func cancel()
}

public extension Loader {
    func load(key: Key) async {
        await loadData(key: key)
    }
    
    func loadData(key: Key) async {
        self.cancellable = self.createPublisher(key: key)?
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.catchCompletion(completion)
            } receiveValue: { [weak self] object in
                self?.object = object
                self?.loadCompleted(key: key, object: object)
            }
    }
    
    func loadCompleted(key: Key, object: Object) {
        // Default implementation does nothing. This is used by the more advanced loaders to allow for inserting cache events.
    }
    
    /// Cancels the ongoing load.
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}

public extension Loader where Key == GenericKey {
    func load() async {
        await load(key: .key)
    }
}
