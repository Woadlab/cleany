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
            return "Svuota Cache DNS"
        case .purgeRAM:
            return "Libera Memoria RAM"
        case .thinTimeMachine:
            return "Ottimizza Snapshot Time Machine"
        case .reindexSpotlight:
            return "Reindicizza Spotlight"
        case .speedUpMail:
            return "Compatta Database Mail"
        }
    }

    public var taskDescription: String {
        switch self {
        case .flushDNS:
            return "Cancella la cache di risoluzione domini inviando una notifica a mDNSResponder."
        case .purgeRAM:
            return "Forza macOS a liberare e comprimere le pagine di cache inattive in memoria."
        case .thinTimeMachine:
            return "Rimuove gli snapshot locali APFS obsoleti per liberare spazio su disco."
        case .reindexSpotlight:
            return "Forza il demone dei metadati a re-indicizzare i file per ricerche istantanee."
        case .speedUpMail:
            return "Compatta e deframmenta i database SQLite degli indici di Apple Mail."
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
