import Foundation
import AppKit

/// Coordinates safe file removal. Defaults to moving items to macOS Trash for undoability.
/// When cleaning items that are already in the Trash, purges them permanently.
public enum SafeDeletionManager {

    public enum DeletionMode: Sendable {
        case moveToTrash
        case permanentDelete
    }

    /// Deletes the specified junk items safely.
    public static func delete(
        items: [JunkItem],
        mode: DeletionMode = .moveToTrash
    ) async -> CleanResult {
        let fileManager = FileManager.default
        var totalBytesReclaimed: UInt64 = 0
        var itemsRemovedCount = 0
        var errors: [String] = []

        for item in items where item.isSelected {
            guard FileUtilities.isSafeToDelete(url: item.url) else {
                errors.append("Skipped protected system location: \(item.path)")
                continue
            }

            guard fileManager.fileExists(atPath: item.url.path) else {
                continue
            }

            let isAlreadyInTrash = item.category == .trashBins ||
                item.path.contains("/.Trash/") ||
                item.path.hasSuffix("/.Trash")

            do {
                if isAlreadyInTrash || mode == .permanentDelete {
                    // Try direct removeItem first; fallback to Finder AppleScript if TCC blocks direct rm
                    do {
                        try fileManager.removeItem(at: item.url)
                    } catch {
                        let script = """
                        tell application "Finder"
                            try
                                delete (POSIX file "\(item.path)" as alias)
                            end try
                        end tell
                        """
                        _ = NSAppleScript(source: script)?.executeAndReturnError(nil)
                    }
                } else {
                    var resultingURL: NSURL?
                    try fileManager.trashItem(at: item.url, resultingItemURL: &resultingURL)
                }

                totalBytesReclaimed += item.size
                itemsRemovedCount += 1
            } catch {
                errors.append("Failed to remove \(item.displayName): \(error.localizedDescription)")
            }
        }

        return CleanResult(
            bytesReclaimed: totalBytesReclaimed,
            itemsRemovedCount: itemsRemovedCount,
            errors: errors,
            timestamp: Date()
        )
    }
}
