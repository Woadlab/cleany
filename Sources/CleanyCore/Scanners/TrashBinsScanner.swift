import Foundation
import AppKit

/// Scans local and iCloud drive Trash bins using the native macOS Finder Apple Event bridge,
/// resolving TCC privacy boundaries reliably across macOS 14 through macOS 27.
public struct TrashBinsScanner: JunkScanner {
    public let category: JunkCategory = .trashBins

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        var items: [JunkItem] = []
        var totalBytes: UInt64 = 0

        // 1. Bulk query Finder for all trash item URLs via single Apple Event
        let trashURLs = await fetchTrashURLs()

        for itemURL in trashURLs {
            let path = itemURL.path
            let cleanPath = path.hasSuffix("/") ? String(path.dropLast()) : path
            let normalizedURL = URL(fileURLWithPath: cleanPath)
            let name = normalizedURL.lastPathComponent

            onProgress(ScanProgress(
                currentCategory: .trashBins,
                currentPath: cleanPath,
                itemsFound: items.count,
                bytesFound: totalBytes
            ))

            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: cleanPath, isDirectory: &isDir)
            guard exists else { continue }

            let size = FileUtilities.calculateSize(at: normalizedURL)
            let values = try? normalizedURL.resourceValues(forKeys: [.contentModificationDateKey])

            let subcategory = cleanPath.contains("Mobile Documents") ? "iCloud Trash" : "Local Trash"

            let item = JunkItem(
                url: normalizedURL,
                displayName: name.isEmpty ? "Trash Item" : name,
                subtitle: cleanPath,
                size: size,
                category: .trashBins,
                subcategory: subcategory,
                isDirectory: isDir.boolValue,
                lastModified: values?.contentModificationDate,
                explanation: "Item resting in your macOS Trash bin.",
                isSelected: true
            )

            items.append(item)
            totalBytes += size
        }

        return items
    }

    /// Fetches all URLs in Trash in a single bulk operation using NSAppleScript
    private func fetchTrashURLs() async -> [URL] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let scriptSource = """
                tell application "Finder"
                    set AppleScript's text item delimiters to linefeed
                    return (get URL of every item of trash) as text
                end tell
                """

                guard let appleScript = NSAppleScript(source: scriptSource) else {
                    continuation.resume(returning: Self.fallbackDirectScan())
                    return
                }

                var errorDict: NSDictionary?
                let descriptor = appleScript.executeAndReturnError(&errorDict)

                if let outText = descriptor.stringValue, !outText.isEmpty {
                    let urls = outText
                        .components(separatedBy: "\n")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .compactMap { URL(string: $0) }
                    continuation.resume(returning: urls)
                } else {
                    continuation.resume(returning: Self.fallbackDirectScan())
                }
            }
        }
    }

    private static func fallbackDirectScan() -> [URL] {
        let homeTrash = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
        if let directContents = try? FileManager.default.contentsOfDirectory(at: homeTrash, includingPropertiesForKeys: nil) {
            return directContents
        }
        return []
    }
}
