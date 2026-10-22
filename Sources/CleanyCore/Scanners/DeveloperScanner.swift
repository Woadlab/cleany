import Foundation

/// Discovers build artifacts, compiler caches, simulator runtimes, and package dependencies.
public struct DeveloperScanner: JunkScanner {
    public let category: JunkCategory = .developerJunk

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        var items: [JunkItem] = []
        var totalBytes: UInt64 = 0

        struct Target {
            let relativePath: String
            let toolName: String
            let subcategory: String
            let description: String
            let scanSubdirectories: Bool
        }

        let targets: [Target] = [
            Target(
                relativePath: "Library/Developer/Xcode/DerivedData",
                toolName: "Xcode",
                subcategory: "DerivedData",
                description: "Intermediate build outputs, module indexes, and project compilation products.",
                scanSubdirectories: true
            ),
            Target(
                relativePath: "Library/Developer/Xcode/Archives",
                toolName: "Xcode",
                subcategory: "Archives",
                description: "Historical application archive builds created for distribution or testing.",
                scanSubdirectories: true
            ),
            Target(
                relativePath: "Library/Developer/Xcode/iOS DeviceSupport",
                toolName: "Xcode",
                subcategory: "Device Support",
                description: "Symbol files for connected iOS devices that can be regenerated on demand.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: "Library/Developer/CoreSimulator/Caches",
                toolName: "CoreSimulator",
                subcategory: "Simulator Caches",
                description: "Temporary data and runtime caches used by macOS iOS/watchOS simulators.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: "Library/Caches/org.swift.swiftpm",
                toolName: "Swift Package Manager",
                subcategory: "Manifest & Git Cache",
                description: "Cached Swift package checkouts and binary artifact downloads.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: "Library/Caches/CocoaPods",
                toolName: "CocoaPods",
                subcategory: "Pods Cache",
                description: "Cached zip archives and git clones of third-party CocoaPods.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: "Library/Caches/Homebrew",
                toolName: "Homebrew",
                subcategory: "Downloaded Bottles",
                description: "Cached tarballs and installer packages downloaded by Homebrew.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: ".npm/_cacache",
                toolName: "npm",
                subcategory: "Package Cache",
                description: "Content-addressable package archive cache for npm.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: ".pnpm-store",
                toolName: "pnpm",
                subcategory: "Content Store",
                description: "Deduplicated package store for pnpm node modules.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: ".cargo/registry/cache",
                toolName: "Cargo / Rust",
                subcategory: "Crate Cache",
                description: "Downloaded .crate archive packages from crates.io.",
                scanSubdirectories: false
            ),
            Target(
                relativePath: ".gradle/caches",
                toolName: "Gradle",
                subcategory: "Build Cache",
                description: "Java/Kotlin Gradle dependency jars and task artifact caches.",
                scanSubdirectories: false
            )
        ]

        for target in targets {
            let targetURL = home.appendingPathComponent(target.relativePath)
            onProgress(ScanProgress(
                currentCategory: .developerJunk,
                currentPath: targetURL.path,
                itemsFound: items.count,
                bytesFound: totalBytes
            ))

            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: targetURL.path, isDirectory: &isDir) else {
                continue
            }

            if target.scanSubdirectories && isDir.boolValue {
                // Discover individual projects/folders inside
                let subURLs = (try? FileManager.default.contentsOfDirectory(
                    at: targetURL,
                    includingPropertiesForKeys: [.contentModificationDateKey],
                    options: [.skipsHiddenFiles]
                )) ?? []

                for subURL in subURLs {
                    let size = FileUtilities.calculateSize(at: subURL)
                    guard size > 0 else { continue }

                    let values = try? subURL.resourceValues(forKeys: [.contentModificationDateKey])
                    let item = JunkItem(
                        url: subURL,
                        displayName: "\(target.subcategory): \(subURL.lastPathComponent)",
                        subtitle: subURL.path.replacingOccurrences(of: home.path, with: "~"),
                        size: size,
                        category: .developerJunk,
                        subcategory: target.toolName,
                        isDirectory: true,
                        lastModified: values?.contentModificationDate,
                        explanation: target.description,
                        isSelected: true
                    )
                    items.append(item)
                    totalBytes += size
                }
            } else {
                let size = FileUtilities.calculateSize(at: targetURL)
                guard size > 0 else { continue }

                let values = try? targetURL.resourceValues(forKeys: [.contentModificationDateKey])
                let item = JunkItem(
                    url: targetURL,
                    displayName: "\(target.toolName) \(target.subcategory)",
                    subtitle: target.relativePath,
                    size: size,
                    category: .developerJunk,
                    subcategory: target.toolName,
                    isDirectory: isDir.boolValue,
                    lastModified: values?.contentModificationDate,
                    explanation: target.description,
                    isSelected: true
                )
                items.append(item)
                totalBytes += size
            }
        }

        return items
    }
}
