import SwiftUI

public extension View {
    /// Presents an alert to the user if an error occurs.
    /// - Parameters:
    ///   - alertContent: Content to display in the alert.
    func errorAlert(isPresented: Binding<Bool>, error optionalError: Error?, message: ((Error) -> String)? = nil, dismiss: @MainActor @escaping () -> Void) -> some View {
        var error: _LocalizedError?
        if let optionalError = optionalError {
            error = _LocalizedError(optionalError)
        }
        
        return body
            .alert(isPresented: isPresented, error: error) { _ in
                Button("OK") {
                    async {
                        await MainActor.run {
                            dismiss()
                        }
                    }
                }
            } message: { error in
                Text(message?(error) ?? error.userVisibleTitle)
            }
    }
}
