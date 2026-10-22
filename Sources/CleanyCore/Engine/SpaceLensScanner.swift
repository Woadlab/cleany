import Foundation

/// Node representing an item in the visual Space Lens storage map.
public struct SpaceNode: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let url: URL
    public let name: String
    public let size: UInt64
    public let isDirectory: Bool
    public let children: [SpaceNode]

    public init(
        id: UUID = UUID(),
        url: URL,
        name: String,
        size: UInt64,
        isDirectory: Bool,
        children: [SpaceNode] = []
    ) {
        self.id = id
        self.url = url
        self.name = name
        self.size = size
        self.isDirectory = isDirectory
        self.children = children
    }

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}

/// Fast directory analyzer for the visual storage treemap.
public enum SpaceLensScanner {

    /// Scans the given directory down to a maximum depth and returns nodes sorted by size.
    public static func scan(
        directory: URL,
        maxDepth: Int = 2,
        currentDepth: Int = 0
    ) async -> SpaceNode {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false

        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDir), isDir.boolValue else {
            let size = FileUtilities.calculateSize(at: directory)
            return SpaceNode(
                url: directory,
                name: directory.lastPathComponent,
                size: size,
                isDirectory: false
            )
        }

        var children: [SpaceNode] = []
        var totalSize: UInt64 = 0

        if currentDepth < maxDepth {
            let contents = (try? fileManager.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )) ?? []

            for childURL in contents {
                var childIsDir: ObjCBool = false
                if fileManager.fileExists(atPath: childURL.path, isDirectory: &childIsDir) {
                    if childIsDir.boolValue {
                        let childNode = await scan(
                            directory: childURL,
                            maxDepth: maxDepth,
                            currentDepth: currentDepth + 1
                        )
                        children.append(childNode)
                        totalSize += childNode.size
                    } else {
                        let size = FileUtilities.calculateSize(at: childURL)
                        totalSize += size
                        children.append(SpaceNode(
                            url: childURL,
                            name: childURL.lastPathComponent,
                            size: size,
                            isDirectory: false
                        ))
                    }
                }
            }
        } else {
            totalSize = FileUtilities.calculateSize(at: directory)
        }

        // Sort largest items first
        let sortedChildren = children.sorted(by: { $0.size > $1.size })

        return SpaceNode(
            url: directory,
            name: directory.lastPathComponent.isEmpty ? directory.path : directory.lastPathComponent,
            size: totalSize,
            isDirectory: true,
            children: sortedChildren
        )
    }
}
