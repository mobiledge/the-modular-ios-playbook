// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureMusicSearch",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureMusicSearch", targets: ["FeatureMusicSearch"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Domain"),
        .package(path: "../Infrastructure")
    ],
    targets: [
        .target(
            name: "FeatureMusicSearch",
            dependencies: ["DesignSystem", "Domain", "Infrastructure"]
        )
    ]
)
