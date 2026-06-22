import Foundation
import Domain

// Console implementations of the telemetry contracts.
//
// These are the same dev/test mocks from Chapter 1, now living in Infrastructure
// where every concrete, outside-world detail belongs. They depend on `Domain`
// (to conform to its protocols) and print through the package's internal
// `Logger`. The real vendor adapters — CrashlyticsReporter, AmplitudeAnalytics,
// a LaunchDarkly-backed flag provider — would sit right here beside them,
// selected by the composition root in Chapter 6. Swapping a vendor never leaves
// this folder.

/// Prints analytics events instead of sending them to a backend.
public struct ConsoleAnalytics: AnalyticsTracker {
    public init() {}

    public func track(_ event: AnalyticsEvent) {
        Logger.log("📊 analytics: \(event.name) \(event.properties)")
    }
}

/// Prints crashes and breadcrumbs instead of uploading them.
public struct ConsoleCrashReporter: CrashReporter {
    public init() {}

    public func record(_ error: Error, context: [String: String]) {
        Logger.log("💥 crash: \(error) \(context)")
    }

    public func breadcrumb(_ message: String) {
        Logger.log("🍞 breadcrumb: \(message)")
    }
}

/// In-memory flags with optional overrides. Stands in for a real remote-config
/// service; later chapters drive the overrides from launch arguments so UI tests
/// can flip a flag deterministically.
public struct LocalFeatureFlags: FeatureFlagProvider {
    private let overrides: [FeatureFlag: Bool]

    public init(_ overrides: [FeatureFlag: Bool] = [:]) {
        self.overrides = overrides
    }

    public func isEnabled(_ flag: FeatureFlag) -> Bool {
        overrides[flag] ?? false
    }
}
