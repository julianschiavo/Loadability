import SwiftUI

public extension View {
    /// Presents an alert to the user if an error occurs.
    /// - Parameters:
    ///   - errorBinding: A binding to an Optional Error. When the binding
    ///     represents a non-`nil` item, an alert will be shown.
    ///   - alert: The contents of the alert to show for an error.
    func alert<E: AnyIdentifiableError>(errorBinding: Binding<E?>,
                                        alert: ((Error) -> Alert)? = nil) -> some View {
        overlay(
            EmptyView()
                .alert(item: errorBinding) { error in
                    guard let alert = alert else {
                        return defaultAlert(for: error)
                    }
                    return alert(error)
                }
        )
    }
    
    /// Presents an alert to the user if an error occurs.
    /// - Parameters:
    ///   - errorBinding: A binding to an Optional Error. When the binding
    ///     represents a non-`nil` item, an alert will be shown.
    ///   - alert: The contents of the alert to show for an error.
    func alert(errorBinding: Binding<IdentifiableError?>,
               alert: ((Error) -> Alert)? = nil) -> some View {
        overlay(
            EmptyView()
                .alert(item: errorBinding) { error in
                    guard let alert = alert else {
                        return defaultAlert(for: error.error)
                    }
                    return alert(error.error)
                }
        )
    }
    
    /// Creates an alert for an error.
    /// - Parameter error: The error.
    /// - Returns: The alert.
    func defaultAlert(for error: Error) -> Alert {
        let title = Text(error.userVisibleTitle)
        let message = Text(error.userVisibleOverallDescription)
        return Alert(title: title, message: message)
    }
}
