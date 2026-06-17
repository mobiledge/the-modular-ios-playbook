// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureMovies",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureMovies", targets: ["FeatureMovies"])
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../Domain")
    ],
    targets: [
        .target(
            name: "FeatureMovies",
            dependencies: ["DesignSystem", "Domain"]
        )
    ]
)
