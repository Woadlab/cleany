// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cleany",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CleanyCore",
            targets: ["CleanyCore"]
        ),
        .executable(
            name: "cleany",
            targets: ["CleanyCLI"]
        ),
        .executable(
            name: "CleanyApp",
            targets: ["CleanyApp"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CleanyCore",
            dependencies: [],
            path: "Sources/CleanyCore",
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .executableTarget(
            name: "CleanyCLI",
            dependencies: ["CleanyCore"],
            path: "Sources/CleanyCLI"
        ),
        .executableTarget(
            name: "CleanyApp",
            dependencies: ["CleanyCore"],
            path: "Sources/CleanyApp"
        ),
        .testTarget(
            name: "CleanyCoreTests",
            dependencies: ["CleanyCore"],
            path: "Tests/CleanyCoreTests"
        )
    ]
)
