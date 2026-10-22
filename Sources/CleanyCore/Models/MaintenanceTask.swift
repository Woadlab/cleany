import Foundation

/// Specific system maintenance operations that can be performed locally.
public enum MaintenanceTask: String, CaseIterable, Identifiable, Sendable, Codable {
    case flushDNS = "flushDNS"
    case purgeRAM = "purgeRAM"
    case thinTimeMachine = "thinTimeMachine"
    case reindexSpotlight = "reindexSpotlight"
    case speedUpMail = "speedUpMail"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .flushDNS:
            return "Flush DNS Cache"
        case .purgeRAM:
            return "Free Inactive Memory"
        case .thinTimeMachine:
            return "Thin Time Machine Snapshots"
        case .reindexSpotlight:
            return "Reindex Spotlight"
        case .speedUpMail:
            return "Speed Up Mail Database"
        }
    }

    public var taskDescription: String {
        switch self {
        case .flushDNS:
            return "Clears local domain resolution caches by notifying mDNSResponder."
        case .purgeRAM:
            return "Forces macOS to compress or discard inactive disk-backed cache pages."
        case .thinTimeMachine:
            return "Removes unneeded local APFS backup snapshots to reclaim purgeable disk space."
        case .reindexSpotlight:
            return "Forces macOS metadata daemon (mdimport) to re-index system files for faster search."
        case .speedUpMail:
            return "Compacts and vacuums SQLite envelope index databases used by Apple Mail."
        }
    }

    public var systemImage: String {
        switch self {
        case .flushDNS:
            return "network"
        case .purgeRAM:
            return "memorychip.fill"
        case .thinTimeMachine:
            return "clock.arrow.circlepath"
        case .reindexSpotlight:
            return "magnifyingglass.circle.fill"
        case .speedUpMail:
            return "envelope.circle.fill"
        }
    }
}
