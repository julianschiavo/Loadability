import Foundation

extension Error {
    /// The `NSError` representation of the error.
    private var nsError: NSError {
        self as NSError
    }
    
    /// The user visible title for the error.
    var userVisibleTitle: String {
        nsError.localizedFailureReason ?? ""
    }
    
    private var description: String? {
        guard !nsError.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "" }
        return nsError.localizedDescription
    }
    
    private var recoverySuggestion: String? {
        guard let suggestion = nsError.localizedRecoverySuggestion,
              !suggestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return nsError.localizedRecoverySuggestion
    }
    
    /// The user visible description for the error.
    var userVisibleOverallDescription: String {
        [description, recoverySuggestion]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
