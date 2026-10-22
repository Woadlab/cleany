import Foundation

/// Scans local and external drive Trash bins.
public struct TrashBinsScanner: JunkScanner {
    public let category: JunkCategory = .trashBins

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        var items: [JunkItem] = []
        var totalBytes: UInt64 = 0

        let trashURL = home.appendingPathComponent(".Trash")

        guard let trashContents = try? FileManager.default.contentsOfDirectory(
            at: trashURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: []
        ) else {
            return []
        }

        for itemURL in trashContents {
            onProgress(ScanProgress(
                currentCategory: .trashBins,
                currentPath: itemURL.path,
                itemsFound: items.count,
                bytesFound: totalBytes
            ))

            let size = FileUtilities.calculateSize(at: itemURL)
            guard size > 0 else { continue }

            var isDir: ObjCBool = false
            _ = FileManager.default.fileExists(atPath: itemURL.path, isDirectory: &isDir)
            let values = try? itemURL.resourceValues(forKeys: [.contentModificationDateKey])

            let item = JunkItem(
                url: itemURL,
                displayName: itemURL.lastPathComponent,
                subtitle: "In Trash",
                size: size,
                category: .trashBins,
                subcategory: "User Trash",
                isDirectory: isDir.boolValue,
                lastModified: values?.contentModificationDate,
                explanation: "File or directory sitting in your macOS Trash bin.",
                isSelected: true
            )
            items.append(item)
            totalBytes += size
        }

        return items
    }
}
