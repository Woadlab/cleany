// swift-tools-version: 6.0
import Foundation
import PackageDescription

var appSwiftSettings: [SwiftSetting] = []

#if os(macOS)
let pipe = Pipe()
let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
process.arguments = ["--show-sdk-version"]
process.standardOutput = pipe
if let _ = try? process.run() {
    process.waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let versionStr = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
       let major = Double(versionStr), major >= 26.0 {
        appSwiftSettings.append(.define("HAS_MACOS26_GLASS"))
    }
}
#endif

let package = Package(
    name: "Cleany",
    platforms: [
        .macOS(.v15)
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
            path: "Sources/CleanyApp",
            swiftSettings: appSwiftSettings
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
