// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppInterfaces",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "AppInterfaces", targets: ["AppInterfaces"])
    ],
    dependencies: [
        .package(path: "../Domain")
    ],
    targets: [
        .target(name: "AppInterfaces", dependencies: ["Domain"])
    ]
)
