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
    
    /// An ongoing task.
    var task: Task.Handle<Void, Error>? { get set }
    
    /// Begins loading the object.
    /// - Parameter key: The key identifying the object to load.
    func load(key: Key) async
    
    /// Creates a publisher that loads the object.
    /// - Parameter key: The key identifying the object to load.
    func createPublisher(key: Key) -> AnyPublisher<Object, Error>?
    
    /// Starts loading the object's data. If you implement `loadData(key:)`, do not implement `createPublisher(key:)`.
    /// - Parameter key: The key identifying the object to load.
    func loadData(key: Key) async throws -> Object
    
    /// Refreshes the data by re-loading it (this resets the cache).
    /// - Parameter key: The key identifying the object to load.
    func refresh(key: Key) async
    
    /// Called when the object has been loaded successfully.
    /// - Parameters:
    ///   - key: The key identifying the object that was loaded.
    ///   - object: The loaded object.
    func loadCompleted(key: Key, object: Object)
    
    /// Cancels the current loading operation.
    func cancel()
}

public extension Loader {
    func load(key: Key) async {
        task = async {
            let object = try await loadData(key: key)
            self.object = object
            loadCompleted(key: key, object: object)
        }
        do {
            try await task?.get()
        } catch {
            catchError(error)
        }
    }
    
    func refresh(key: Key) async {
        cancel()
        object = nil
        await load(key: key)
    }
    
    func loadData(key: Key) async throws -> Object {
        guard let publisher = createPublisher(key: key) else {
            fatalError("You must implement either loadData or createPublisher.")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            var didFinish = false
            cancellable = publisher
                .subscribe(on: DispatchQueue.global(qos: .userInitiated))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    guard case let .failure(error) = completion, !didFinish else { return }
                    didFinish = true
                    continuation.resume(throwing: error)
                } receiveValue: { object in
                    guard !didFinish else { return }
                    didFinish = true
                    continuation.resume(returning: object)
                }
        }
    }
    
    func createPublisher(key: Key) -> AnyPublisher<Object, Error>? {
        // Default implementation does nothing. This method is optional if `loadData(key:)` is implemented.
        return nil
    }
    
    func loadCompleted(key: Key, object: Object) {
        // Default implementation does nothing. This is used by the more advanced loaders to allow for inserting cache events.
    }
    
    /// Cancels the ongoing load.
    func cancel() {
        task?.cancel()
        task = nil
        
        cancellable?.cancel()
        cancellable = nil
    }
}

public extension Loader where Key == GenericKey {
    func load() async {
        await load(key: .key)
    }
}
