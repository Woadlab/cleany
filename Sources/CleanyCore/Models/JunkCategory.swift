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
            return "Cache & Modelli AI"
        case .developerJunk:
            return "Residui Sviluppo"
        case .systemJunk:
            return "File di Sistema"
        case .appLeftovers:
            return "Residui Applicazioni"
        case .trashBins:
            return "Cestino"
        }
    }

    public var subtitle: String {
        switch self {
        case .aiClutter:
            return "Cache, log e snapshot da Cursor, Claude, Ollama e LM Studio"
        case .developerJunk:
            return "Xcode DerivedData, simulatori e cache dei package manager"
        case .systemJunk:
            return "Cache utente, registri di sistema e log di crash"
        case .appLeftovers:
            return "Cartelle orfane e file residui di app già disinstallate"
        case .trashBins:
            return "Elementi e file accumulati nel Cestino di macOS"
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
            return "AI"
        case .developerJunk:
            return "Dev"
        case .systemJunk:
            return "macOS"
        case .appLeftovers:
            return "App"
        case .trashBins:
            return nil
        }
    }
}
