/// A shared cache.
public protocol AnySharedCache {
    associatedtype Key: Hashable & Identifiable
    associatedtype Value
    
    static subscript(key: Key) -> Value? { get set }
    static func isValueStale(_ key: Key) -> Bool
}
