// swift-tools-version: 5.9
import PackageDescription

// Chapter 7: the Music Search feature is split into three micro-modules.
// UI and Logic both depend on Interface — but NOT on each other.
let package = Package(
    name: "FeatureMusicSearch",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "MusicSearchInterface", targets: ["MusicSearchInterface"]),
        .library(name: "MusicSearchUI", targets: ["MusicSearchUI"]),
        .library(name: "MusicSearchLogic", targets: ["MusicSearchLogic"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Domain")
    ],
    targets: [
        // Protocols + the feature's public contract. No UIKit/SwiftUI logic.
        .target(name: "MusicSearchInterface", dependencies: ["Domain"]),
        // Views only. Depends on Interface (the view-model contract) + DesignSystem.
        .target(name: "MusicSearchUI", dependencies: ["MusicSearchInterface", "DesignSystem", "Domain"]),
        // ViewModel only. Depends on Interface + Domain. No SwiftUI views.
        .target(name: "MusicSearchLogic", dependencies: ["MusicSearchInterface", "Domain"])
    ]
)
