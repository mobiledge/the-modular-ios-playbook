import SwiftUI

/// The app's design tokens. Shared by every feature.
///
/// MONOLITH NOTE: because this lives in the same target as everything else,
/// any view can use it freely — but there is also nothing stopping unrelated
/// code from depending on it. Chapter 2 extracts these into a Design System module.
enum AppColors {
    static let primary = Color(red: 0.92, green: 0.18, blue: 0.36)
    static let secondaryText = Color.secondary
    static let cardBackground = Color(.secondarySystemBackground)
}
