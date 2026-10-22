import Foundation
import AppKit

/// Scans local and iCloud drive Trash bins using the native macOS Finder Apple Event bridge.
/// Accurately computes total Trash size and item count even when individual file inspection is restricted by macOS TCC.
public struct TrashBinsScanner: JunkScanner {
    public let category: JunkCategory = .trashBins

    public init() {}

    public func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem] {
        var items: [JunkItem] = []

        onProgress(ScanProgress(
            currentCategory: .trashBins,
            currentPath: "Calcolo spazio Cestino...",
            itemsFound: 0,
            bytesFound: 0
        ))

        // 1. Query Finder for trash items count and sizes
        let (itemCount, totalSize) = await fetchTrashSummary()

        if itemCount > 0 {
            // Also attempt to get individual item names/URLs if permitted
            let trashURLs = await fetchTrashURLs()

            if !trashURLs.isEmpty {
                for itemURL in trashURLs {
                    let path = itemURL.path
                    let cleanPath = path.hasSuffix("/") ? String(path.dropLast()) : path
                    let normalizedURL = URL(fileURLWithPath: cleanPath)
                    let name = normalizedURL.lastPathComponent

                    var isDir: ObjCBool = false
                    _ = FileManager.default.fileExists(atPath: cleanPath, isDirectory: &isDir)
                    let size = FileUtilities.calculateSize(at: normalizedURL)
                    let values = try? normalizedURL.resourceValues(forKeys: [.contentModificationDateKey])

                    let item = JunkItem(
                        url: normalizedURL,
                        displayName: name.isEmpty ? "Elemento nel Cestino" : name,
                        subtitle: cleanPath,
                        size: size > 0 ? size : (totalSize / UInt64(max(1, trashURLs.count))),
                        category: .trashBins,
                        subcategory: "Cestino macOS",
                        isDirectory: isDir.boolValue,
                        lastModified: values?.contentModificationDate,
                        explanation: "File o directory attualmente presente nel Cestino di macOS.",
                        isSelected: true
                    )
                    items.append(item)
                }
            } else {
                // TCC restricts individual file listing: provide clean aggregated Trash representation
                let aggregatedItem = JunkItem(
                    url: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash"),
                    displayName: "File ed elementi nel Cestino",
                    subtitle: "\(itemCount) elementi archiviati nel Cestino",
                    size: totalSize,
                    category: .trashBins,
                    subcategory: "Cestino macOS",
                    isDirectory: true,
                    lastModified: Date(),
                    explanation: "macOS protegge l'accesso ai singoli file nel Cestino. Svuotando il Cestino libererai questo spazio.",
                    isSelected: true
                )
                items.append(aggregatedItem)
            }
        }

        onProgress(ScanProgress(
            currentCategory: .trashBins,
            currentPath: "Cestino completato",
            itemsFound: items.count,
            bytesFound: items.reduce(0) { $0 + $1.size }
        ))

        return items
    }

    /// Queries Finder for total item count and cumulative byte size
    private func fetchTrashSummary() async -> (Int, UInt64) {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let scriptSource = """
                tell application "Finder"
                    set totalSize to 0
                    set allItems to every item of trash
                    set itemCount to count allItems
                    repeat with anItem in allItems
                        try
                            set s to size of anItem
                            if s is not missing value then
                                set totalSize to totalSize + s
                            end if
                        end try
                    end repeat
                    return (itemCount as text) & "," & (totalSize as text)
                end tell
                """

                guard let appleScript = NSAppleScript(source: scriptSource) else {
                    continuation.resume(returning: Self.fallbackDirectSummary())
                    return
                }

                var errorDict: NSDictionary?
                let descriptor = appleScript.executeAndReturnError(&errorDict)

                if let outText = descriptor.stringValue, !outText.isEmpty {
                    let parts = outText.components(separatedBy: ",")
                    let count = Int(parts.first ?? "0") ?? 0
                    let sizeStr = parts.count > 1 ? parts[1] : "0"
                    let size = UInt64(Double(sizeStr) ?? 0)
                    continuation.resume(returning: (count, size))
                } else {
                    continuation.resume(returning: Self.fallbackDirectSummary())
                }
            }
        }
    }

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
                    continuation.resume(returning: [])
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
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private static func fallbackDirectSummary() -> (Int, UInt64) {
        let homeTrash = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".Trash")
        guard let directContents = try? FileManager.default.contentsOfDirectory(at: homeTrash, includingPropertiesForKeys: nil) else {
            return (0, 0)
        }
        let size = directContents.reduce(0) { $0 + FileUtilities.calculateSize(at: $1) }
        return (directContents.count, size)
    }
}
