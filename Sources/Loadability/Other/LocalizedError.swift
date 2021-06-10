import Foundation

struct _LocalizedError: LocalizedError {
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        error.userVisibleTitle
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        nil
    }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? {
        error.recoverySuggestion
    }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? {
        nil
    }
    
    /// The underlying error object.
    var error: Error
    
    init(_ error: Error) {
        self.error = error
    }
}
