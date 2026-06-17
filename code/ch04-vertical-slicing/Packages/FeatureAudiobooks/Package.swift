// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureAudiobooks",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureAudiobooks", targets: ["FeatureAudiobooks"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Domain"),
        .package(path: "../Infrastructure")
    ],
    targets: [
        .target(
            name: "FeatureAudiobooks",
            dependencies: ["DesignSystem", "Domain", "Infrastructure"]
        )
    ]
)
