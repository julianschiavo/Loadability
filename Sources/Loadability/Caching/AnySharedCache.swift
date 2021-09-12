/// A shared cache.
public protocol AnySharedCache {
    associatedtype Key: Hashable & Identifiable
    associatedtype Value
    
//    static subscript(key: Key) -> Value? { get set }
    static func value(for key: Key) async -> Value?
    static func update(key: Key, to value: Value) async
    static func remove(_ key: Key) async
    static func isValueStale(_ key: Key) -> Bool
}
