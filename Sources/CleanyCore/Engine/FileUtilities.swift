import Foundation

/// Low-level filesystem helpers for calculating byte sizes and validating path safety.
public enum FileUtilities {

    /// Recursively calculates the byte size of a file or directory.
    public static func calculateSize(at url: URL) -> UInt64 {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDir) else {
            return 0
        }

        if !isDir.boolValue {
            do {
                let values = try url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey])
                return UInt64(values.totalFileAllocatedSize ?? values.fileSize ?? 0)
            } catch {
                return 0
            }
        }

        // For directories, traverse with resource values
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else {
            return 0
        }

        var totalSize: UInt64 = 0
        while let fileURL = enumerator.nextObject() as? URL {
            do {
                let values = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileSizeKey, .isRegularFileKey])
                if values.isRegularFile == true {
                    let size = values.totalFileAllocatedSize ?? values.fileSize ?? 0
                    totalSize += UInt64(size)
                }
            } catch {
                continue
            }
        }
        return totalSize
    }

    /// Validates that a path is safe for cleaning and not a critical macOS system component.
    public static func isSafeToDelete(url: URL) -> Bool {
        let standardPath = url.standardizedFileURL.path
        let homePath = FileManager.default.homeDirectoryForCurrentUser.standardizedFileURL.path

        // Disallow root or direct user home
        if standardPath == "/" || standardPath == homePath {
            return false
        }

        // Protected system prefixes
        let dangerousPrefixes = [
            "/System",
            "/bin",
            "/sbin",
            "/usr",
            "/private/var/db",
            "/Library/Apple",
            "/Library/CoreMediaIO"
        ]

        for prefix in dangerousPrefixes {
            if standardPath.hasPrefix(prefix) {
                return false
            }
        }

        // Protected user folders
        let protectedUserFolders = [
            "\(homePath)/Desktop",
            "\(homePath)/Documents",
            "\(homePath)/Downloads",
            "\(homePath)/Pictures",
            "\(homePath)/Music",
            "\(homePath)/Movies",
            "\(homePath)/Applications",
            "\(homePath)/Library/Keychains",
            "\(homePath)/Library/Safari"
        ]

        for protected in protectedUserFolders {
            if standardPath == protected {
                return false
            }
        }

        return true
    }
}
