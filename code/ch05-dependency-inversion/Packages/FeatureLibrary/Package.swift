// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureLibrary",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureLibrary", targets: ["FeatureLibrary"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Domain"),
        // For the LibraryRouter abstraction — NOT for any concrete feature.
        .package(path: "../AppInterfaces")
    ],
    targets: [
        .target(
            name: "FeatureLibrary",
            dependencies: ["DesignSystem", "Domain", "AppInterfaces"]
        )
    ]
)
