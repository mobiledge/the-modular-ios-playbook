// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureMusicSearch",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureMusicSearch", targets: ["FeatureMusicSearch"])
    ],
    dependencies: [
        // No Infrastructure! The feature depends only on UI + domain abstractions.
        .package(path: "../DesignSystem"),
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "FeatureMusicSearch",
            dependencies: ["DesignSystem", "Domain"]
        )
    ]
)
