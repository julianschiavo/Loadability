/// A generic key, used when the loadable value is not keyed by anything.
public enum GenericKey: String, Codable, Hashable, Identifiable {
    /// A generic key, used when the loadable value is not keyed by anything.
    case key
    
    /// The stable identity of the entity associated with this instance.
    public var id: String { rawValue }
}
