/// A shared cache.
public protocol AnySharedCache {
    associatedtype Key: Hashable & Identifiable
    associatedtype Value
    
//    static subscript(key: Key) -> Value? { get set }
    static func value(for key: Key) async throws -> Value?
    static func update(key: Key, to value: Value) async throws
    static func removeValue(for key: Key) async throws
    static func isValueStale(_ key: Key) -> Bool
}
