import Foundation

/// Scans user application caches, diagnostic logs, and temporary crash reports.
public struct SystemJunkScanner: JunkScanner {
    public let category: JunkCategory = .systemJunk

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        var items: [JunkItem] = []
        var totalBytes: UInt64 = 0

        let cachesDirectory = home.appendingPathComponent("Library/Caches")
        let logsDirectory = home.appendingPathComponent("Library/Logs")

        // 1. App Caches in ~/Library/Caches
        if let subdirs = try? FileManager.default.contentsOfDirectory(
            at: cachesDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) {
            for subURL in subdirs {
                let name = subURL.lastPathComponent

                // Skip active critical caches to prevent unexpected app re-login
                if name.contains("CloudKit") || name.contains("accounts") || name == "com.apple.HomeKit" {
                    continue
                }

                onProgress(ScanProgress(
                    currentCategory: .systemJunk,
                    currentPath: subURL.path,
                    itemsFound: items.count,
                    bytesFound: totalBytes
                ))

                let size = FileUtilities.calculateSize(at: subURL)
                // Filter small items (< 2 MB) to keep UI clean and high-signal
                guard size > 2 * 1024 * 1024 else { continue }

                var isDir: ObjCBool = false
                _ = FileManager.default.fileExists(atPath: subURL.path, isDirectory: &isDir)
                let values = try? subURL.resourceValues(forKeys: [.contentModificationDateKey])

                let item = JunkItem(
                    url: subURL,
                    displayName: "User Cache: \(name)",
                    subtitle: subURL.path.replacingOccurrences(of: home.path, with: "~"),
                    size: size,
                    category: .systemJunk,
                    subcategory: "User Caches",
                    isDirectory: isDir.boolValue,
                    lastModified: values?.contentModificationDate,
                    explanation: "Temporary data cached by this application to speed up subsequent launches.",
                    isSelected: true
                )
                items.append(item)
                totalBytes += size
            }
        }

        // 2. User Logs in ~/Library/Logs
        if let logDirs = try? FileManager.default.contentsOfDirectory(
            at: logsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) {
            for logURL in logDirs {
                let name = logURL.lastPathComponent

                onProgress(ScanProgress(
                    currentCategory: .systemJunk,
                    currentPath: logURL.path,
                    itemsFound: items.count,
                    bytesFound: totalBytes
                ))

                let size = FileUtilities.calculateSize(at: logURL)
                guard size > 500 * 1024 else { continue } // > 500 KB

                var isDir: ObjCBool = false
                _ = FileManager.default.fileExists(atPath: logURL.path, isDirectory: &isDir)
                let values = try? logURL.resourceValues(forKeys: [.contentModificationDateKey])

                let item = JunkItem(
                    url: logURL,
                    displayName: "Log Folder: \(name)",
                    subtitle: logURL.path.replacingOccurrences(of: home.path, with: "~"),
                    size: size,
                    category: .systemJunk,
                    subcategory: "System & App Logs",
                    isDirectory: isDir.boolValue,
                    lastModified: values?.contentModificationDate,
                    explanation: "Historical event and diagnostic logs recorded during application execution.",
                    isSelected: true
                )
                items.append(item)
                totalBytes += size
            }
        }

        return items
    }
}
