import Foundation

/// Primary classification of junk and clutter that Cleany can scan and safely clean.
public enum JunkCategory: String, CaseIterable, Identifiable, Sendable, Codable {
    case aiClutter = "aiClutter"
    case developerJunk = "developerJunk"
    case systemJunk = "systemJunk"
    case appLeftovers = "appLeftovers"
    case trashBins = "trashBins"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .aiClutter:
            return "AI Clutter"
        case .developerJunk:
            return "Developer Junk"
        case .systemJunk:
            return "System Junk"
        case .appLeftovers:
            return "App Leftovers"
        case .trashBins:
            return "Trash Bins"
        }
    }

    public var subtitle: String {
        switch self {
        case .aiClutter:
            return "Caches, logs, and model weights from Claude, Cursor, Ollama & LM Studio"
        case .developerJunk:
            return "Xcode DerivedData, simulators, and package manager caches"
        case .systemJunk:
            return "User caches, system logs, crash reports, and universal binaries"
        case .appLeftovers:
            return "Orphaned preferences and containers from uninstalled applications"
        case .trashBins:
            return "Files currently in local and external drive Trash bins"
        }
    }

    public var systemImage: String {
        switch self {
        case .aiClutter:
            return "sparkles.square.filled.on.square"
        case .developerJunk:
            return "hammer.fill"
        case .systemJunk:
            return "gearshape.2.fill"
        case .appLeftovers:
            return "trash.square.fill"
        case .trashBins:
            return "trash.fill"
        }
    }

    public var badge: String? {
        switch self {
        case .aiClutter:
            return "New"
        default:
            return nil
        }
    }
}
