# Core Infrastructure Implementation

Infrastructure defines cross-cutting capabilities without exposing *how* they are achieved.

### 1. Interface (The Abstraction)

Lives in `CoreInfrastructure/Interface`.

```swift
public protocol AnalyticsService: Sendable {
    func trackEvent(_ name: String, properties: [String: String])
}

public protocol FeatureFlagService: Sendable {
    func isEnabled(_ feature: Feature) -> Bool
}

public enum Feature: String, Sendable {
    case newSearchAlgorithm
}

```

### 2. Implementation (The Concretion)

Lives in `CoreInfrastructure/Implementation`. This is the ONLY place that imports third-party SDKs like Firebase, Mixpanel, or Datadog.

```swift
import CoreInfrastructureInterface
import os // Or Mixpanel, Firebase, etc.

public struct OSLogAnalyticsService: AnalyticsService {
    private let logger = Logger(subsystem: "com.app", category: "Analytics")

    public init() {}

    public func trackEvent(_ name: String, properties: [String: String]) {
        logger.info("Event: \(name) | \(properties)")
    }
}

```
