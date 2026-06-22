import Foundation

// MARK: - Contracts (vendor-agnostic)
//
// These three protocols are the seam between our app and the third-party
// services that observe it: a crash reporter, an analytics backend, and a
// remote feature-flag service. We will swap the real vendors (Crashlytics,
// Amplitude, LaunchDarkly, …) over the life of the app, but the *contracts*
// below should not have to change when we do.
//
// MONOLITH NOTE: today these protocols, their console implementations, AND the
// global that picks between them all live in the same target as the features
// that call them. Nothing stops a view from importing a vendor SDK directly.
// In later chapters the contracts move to `Domain`, the implementations to
// `Infrastructure`, and the selection moves into a composition root — until,
// finally, the whole thing becomes its own `Observability` SPM package whose
// vendor SDKs never link into a Debug or test build.

protocol AnalyticsTracker {
    func track(_ event: AnalyticsEvent)
}

protocol CrashReporter {
    func record(_ error: Error, context: [String: String])
    func breadcrumb(_ message: String)
}

protocol FeatureFlagProvider {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}

// MARK: - Typed payloads
//
// Strongly typed so call sites can't drift into stringly-typed junk, and so the
// set of events and flags is discoverable from one place.

struct AnalyticsEvent {
    let name: String
    let properties: [String: String]

    init(_ name: String, _ properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

enum FeatureFlag: String {
    case newPodcastUI
    case offlineMode
}

// MARK: - Dev/test implementations
//
// The only implementations that exist in Chapter 1. They print through the same
// `Logger` facade the rest of the app uses, so the app runs with zero real SDKs
// linked. The "real" vendor adapters arrive in a later chapter.

struct ConsoleAnalytics: AnalyticsTracker {
    func track(_ event: AnalyticsEvent) {
        Logger.log("📊 analytics: \(event.name) \(event.properties)")
    }
}

struct ConsoleCrashReporter: CrashReporter {
    func record(_ error: Error, context: [String: String]) {
        Logger.log("💥 crash: \(error) \(context)")
    }
    func breadcrumb(_ message: String) {
        Logger.log("🍞 breadcrumb: \(message)")
    }
}

/// In-memory flags. Defaults live here for now; later chapters drive overrides
/// from launch arguments so UI tests can flip a flag deterministically.
struct LocalFeatureFlags: FeatureFlagProvider {
    private let overrides: [FeatureFlag: Bool]

    init(_ overrides: [FeatureFlag: Bool] = [:]) {
        self.overrides = overrides
    }

    func isEnabled(_ flag: FeatureFlag) -> Bool {
        overrides[flag] ?? false
    }
}

// MARK: - The build-selected facade
//
// MONOLITH NOTE: a single global picks the implementation by build
// configuration. The `MOCK_SERVICES` flag is set for the Debug config in
// project.yml; Release would instead point at the real vendor adapters. This
// global is the thing we pay down later — in Chapter 6 the choice moves into a
// composition root and these properties stop being globals entirely.

enum Telemetry {
    #if MOCK_SERVICES
    static let analytics: AnalyticsTracker = ConsoleAnalytics()
    static let crashReporter: CrashReporter = ConsoleCrashReporter()
    static let flags: FeatureFlagProvider = LocalFeatureFlags([.newPodcastUI: true])
    #else
    // Release build. These will become the real vendor adapters
    // (e.g. CrashlyticsReporter(), AmplitudeAnalytics()) in a later chapter;
    // for now the console implementations keep the monolith runnable.
    static let analytics: AnalyticsTracker = ConsoleAnalytics()
    static let crashReporter: CrashReporter = ConsoleCrashReporter()
    static let flags: FeatureFlagProvider = LocalFeatureFlags()
    #endif
}
