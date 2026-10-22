import Foundation

/// State reported by scanners during an active scan pass.
public struct ScanProgress: Sendable, Equatable {
    public let currentCategory: JunkCategory?
    public let currentPath: String
    public let itemsFound: Int
    public let bytesFound: UInt64
    public let fractionCompleted: Double?

    public init(
        currentCategory: JunkCategory? = nil,
        currentPath: String = "",
        itemsFound: Int = 0,
        bytesFound: UInt64 = 0,
        fractionCompleted: Double? = nil
    ) {
        self.currentCategory = currentCategory
        self.currentPath = currentPath
        self.itemsFound = itemsFound
        self.bytesFound = bytesFound
        self.fractionCompleted = fractionCompleted
    }

    public var formattedBytes: String {
        ByteCountFormatter.string(fromByteCount: Int64(bytesFound), countStyle: .file)
    }
}

/// The result returned after executing a cleaning operation.
public struct CleanResult: Sendable, Codable {
    public let bytesReclaimed: UInt64
    public let itemsRemovedCount: Int
    public let errors: [String]
    public let timestamp: Date

    public init(
        bytesReclaimed: UInt64,
        itemsRemovedCount: Int,
        errors: [String] = [],
        timestamp: Date = Date()
    ) {
        self.bytesReclaimed = bytesReclaimed
        self.itemsRemovedCount = itemsRemovedCount
        self.errors = errors
        self.timestamp = timestamp
    }

    public var formattedBytes: String {
        ByteCountFormatter.string(fromByteCount: Int64(bytesReclaimed), countStyle: .file)
    }

    public var isSuccess: Bool {
        errors.isEmpty
    }
}
