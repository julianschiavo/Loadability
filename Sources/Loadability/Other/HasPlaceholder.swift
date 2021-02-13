import SwiftUI

/// A view that has a placeholder
public protocol HasPlaceholder: View {
    associatedtype Placeholder: View
    
    /// A placeholder for the view, optionally annotated with `redacted(reason:)` to use a system-default placeholder style on placeholder content.
    static var placeholder: Placeholder { get }
}
