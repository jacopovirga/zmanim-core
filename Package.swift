// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZmanimCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "ZmanimCore", targets: ["ZmanimCore"])
    ],
    targets: [
        .target(name: "ZmanimCore"),
        .testTarget(
            name: "ZmanimCoreTests",
            dependencies: ["ZmanimCore"],
            resources: [.copy("Fixtures/reference.json")]
        )
    ]
)
