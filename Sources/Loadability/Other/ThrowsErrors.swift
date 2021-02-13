import Combine
import SwiftUI

/// A type that can throw errors that should be shown to the user.
public protocol ThrowsErrors {
    /// An error, if one occurred. Must be annotated with a publisher property wrapper, such as `@State` or `@Published`, to work.
    var error: IdentifiableError? { get nonmutating set }
}

public extension ThrowsErrors {
    /// Attempts to execute a block, catching errors thrown by displaying the error to the user.
    /// - Parameter block: A throwing block.
    func tryAndCatch(_ block: () throws -> Void) {
        do {
            try block()
        } catch {
            catchError(error)
        }
    }
    
    /// Catches a thrown error, updating the view state to display the error if a subscriber is subscribed to it (through `View.alert(errorBinding: $error)`).
    /// - Parameter error: The error that occurred.
    func catchError(_ error: Error?) {
        DispatchQueue.main.async {
            self.error = IdentifiableError(error)
        }
    }
    
    /// Dismisses the current error, if there is one.
    func dismissError() {
        DispatchQueue.main.async {
            self.error = nil
        }
    }
    
    /// Catches an error thrown from a Combine Publisher.
    /// - Parameter completion: The completion received from the publisher.
    func catchCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case let .failure(error) = completion else { return }
        catchError(error)
    }
}
