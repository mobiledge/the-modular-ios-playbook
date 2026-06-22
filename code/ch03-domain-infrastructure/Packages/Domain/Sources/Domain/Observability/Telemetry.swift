import Foundation

// Telemetry contracts — the vendor-agnostic seam first introduced in Chapter 1.
//
// In the monolith these protocols lived in the app target next to their console
// mocks. Now they move *inward* to the Domain layer, because they describe what
// the app needs ("track this event", "is this flag on?") without saying who
// provides it. The Dependency Rule applies exactly as it does to repositories:
// the Domain declares the protocol; Infrastructure implements it; the vendor SDK
// never crosses this line.

/// What the app needs in order to report analytics — not who provides it.
public protocol AnalyticsTracker: Sendable {
    func track(_ event: AnalyticsEvent)
}

/// What the app needs in order to report crashes and breadcrumbs.
public protocol CrashReporter: Sendable {
    func record(_ error: Error, context: [String: String])
    func breadcrumb(_ message: String)
}

/// What the app needs in order to read remote feature flags.
public protocol FeatureFlagProvider: Sendable {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}

// MARK: - Typed payloads

/// A single analytics event. Typed so the vocabulary lives in one place and a
/// typo can't silently invent a new event name.
public struct AnalyticsEvent: Sendable, Equatable {
    public let name: String
    public let properties: [String: String]

    public init(_ name: String, _ properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

/// The set of remote-configurable flags the app understands.
public enum FeatureFlag: String, CaseIterable, Hashable, Sendable {
    case newPodcastUI
    case offlineMode
}
