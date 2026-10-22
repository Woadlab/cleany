import Foundation

/// Represents a distinct file or folder discovered during a scan that is safe to remove or move to Trash.
public struct JunkItem: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public let url: URL
    public let displayName: String
    public let subtitle: String
    public let size: UInt64
    public let category: JunkCategory
    public let subcategory: String
    public let isDirectory: Bool
    public let lastModified: Date?
    public let explanation: String
    public var isSelected: Bool

    public init(
        id: UUID = UUID(),
        url: URL,
        displayName: String,
        subtitle: String,
        size: UInt64,
        category: JunkCategory,
        subcategory: String,
        isDirectory: Bool,
        lastModified: Date? = nil,
        explanation: String,
        isSelected: Bool = true
    ) {
        self.id = id
        self.url = url
        self.displayName = displayName
        self.subtitle = subtitle
        self.size = size
        self.category = category
        self.subcategory = subcategory
        self.isDirectory = isDirectory
        self.lastModified = lastModified
        self.explanation = explanation
        self.isSelected = isSelected
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    public var path: String {
        url.path
    }
}
