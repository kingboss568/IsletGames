// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"])
    ],
    targets: [
        .target(name: "SharedCore"),
        .testTarget(name: "SharedCoreTests", dependencies: ["SharedCore"])
    ]
)