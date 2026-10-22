// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Cleany",
    platforms: [
        .macOS("27.0")
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
            path: "Tests/CleanyCoreTests",
            swiftSettings: [
                .unsafeFlags([
                    "-load-plugin-library",
                    "/Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing/libTestingMacros.dylib"
                ])
            ]
        )
    ]
)
