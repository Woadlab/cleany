import Foundation

/// Detects leftover configuration and data folders from uninstalled applications.
public struct AppLeftoversScanner: JunkScanner {
    public let category: JunkCategory = .appLeftovers

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        var items: [JunkItem] = []
        var totalBytes: UInt64 = 0

        // 1. Gather all installed applications (bundle IDs and folder names)
        var installedIdentifiers: Set<String> = []
        var installedNames: Set<String> = []

        let appLocations = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            home.appendingPathComponent("Applications")
        ]

        for location in appLocations {
            guard let appDirs = try? FileManager.default.contentsOfDirectory(
                at: location,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for appURL in appDirs where appURL.pathExtension == "app" {
                let nameWithoutExtension = appURL.deletingPathExtension().lastPathComponent.lowercased()
                installedNames.insert(nameWithoutExtension)

                let plistURL = appURL.appendingPathComponent("Contents/Info.plist")
                if let data = try? Data(contentsOf: plistURL),
                   let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                   let bundleID = plist["CFBundleIdentifier"] as? String {
                    installedIdentifiers.insert(bundleID.lowercased())
                }
            }
        }

        // 2. Scan ~/Library/Application Support for orphaned folders
        let appSupportDir = home.appendingPathComponent("Library/Application Support")
        if let supportDirs = try? FileManager.default.contentsOfDirectory(
            at: appSupportDir,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) {
            for dirURL in supportDirs {
                let folderName = dirURL.lastPathComponent
                let lower = folderName.lowercased()

                // Skip standard Apple system folders
                if lower.starts(with: "com.apple.") || lower == "apple" || lower == "cloudkit" || lower == "addressbook" || lower == "dock" || lower == "crashreporter" || lower == "icloud" {
                    continue
                }

                onProgress(ScanProgress(
                    currentCategory: .appLeftovers,
                    currentPath: dirURL.path,
                    itemsFound: items.count,
                    bytesFound: totalBytes
                ))

                // Check if this folder corresponds to any currently installed app
                let isInstalled = installedIdentifiers.contains(lower) ||
                                  installedNames.contains(lower) ||
                                  installedNames.contains(lower.replacingOccurrences(of: " ", with: ""))

                if !isInstalled {
                    let size = FileUtilities.calculateSize(at: dirURL)
                    guard size > 100 * 1024 else { continue } // > 100 KB

                    var isDir: ObjCBool = false
                    _ = FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDir)
                    let values = try? dirURL.resourceValues(forKeys: [.contentModificationDateKey])

                    let item = JunkItem(
                        url: dirURL,
                        displayName: "Orphaned App Support: \(folderName)",
                        subtitle: dirURL.path.replacingOccurrences(of: home.path, with: "~"),
                        size: size,
                        category: .appLeftovers,
                        subcategory: "Application Support",
                        isDirectory: isDir.boolValue,
                        lastModified: values?.contentModificationDate,
                        explanation: "Residual preferences and saved data for an application that is no longer installed.",
                        isSelected: true
                    )
                    items.append(item)
                    totalBytes += size
                }
            }
        }

        return items
    }
}
