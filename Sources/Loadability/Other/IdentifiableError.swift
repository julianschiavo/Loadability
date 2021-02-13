import Foundation

public typealias AnyIdentifiableError = Error & Identifiable

/// A uniquely identifiable error.
public struct IdentifiableError: Error, Equatable, Identifiable {
    /// A unique identifier for the error.
    public var id: String
    
    /// The underlying error object.
    public var error: Error
    
    /// Creates a new `IdentifiableError`.
    /// - Parameters:
    ///   - underlyingError: The underlying `Error`.
    ///   - id: An optional identifier for the error.
    public init?(_ underlyingError: Error?, id: String? = nil) {
        guard let error = underlyingError else { return nil }
        
        let nsError = error as NSError
        if let id = id, !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.id = id
        } else if nsError.domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.id = UUID().uuidString
        } else {
            self.id = nsError.domain + String(nsError.code) + error.localizedDescription
        }
        
        self.error = error
    }
    
    /// Checks whether two errors are the same
    /// - Parameters:
    ///   - lhs: An error
    ///   - rhs: Another error
    /// - Returns: Whether the errors are the same
    public static func == (lhs: IdentifiableError, rhs: IdentifiableError) -> Bool {
        lhs.id == rhs.id
    }
}
