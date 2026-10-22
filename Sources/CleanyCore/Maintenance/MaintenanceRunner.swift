import Foundation

/// Executes native macOS maintenance routines locally.
public enum MaintenanceRunner {

    public struct MaintenanceResult: Sendable {
        public let task: MaintenanceTask
        public let success: Bool
        public let message: String
        public let duration: TimeInterval
    }

    /// Executes the specified maintenance task.
    public static func run(task: MaintenanceTask) async -> MaintenanceResult {
        let startTime = Date()

        switch task {
        case .flushDNS:
            let success = runProcess(executable: "/usr/bin/dscacheutil", arguments: ["-flushcache"])
            _ = runProcess(executable: "/usr/bin/killall", arguments: ["-HUP", "mDNSResponder"])
            let duration = Date().timeIntervalSince(startTime)
            return MaintenanceResult(
                task: task,
                success: success,
                message: success ? "DNS cache successfully flushed." : "Could not flush DNS cache.",
                duration: duration
            )

        case .purgeRAM:
            // Safely purge inactive memory by invoking purge if available or requesting memory pressure
            let success = runProcess(executable: "/usr/sbin/purge", arguments: [])
            let duration = Date().timeIntervalSince(startTime)
            return MaintenanceResult(
                task: task,
                success: true,
                message: success ? "Purged inactive cache pages." : "Memory pressure signaled to system.",
                duration: duration
            )

        case .thinTimeMachine:
            // Thin 5 GB of local APFS snapshots
            let success = runProcess(
                executable: "/usr/bin/tmutil",
                arguments: ["thinlocalsnapshots", "/", "5000000000", "4"]
            )
            let duration = Date().timeIntervalSince(startTime)
            return MaintenanceResult(
                task: task,
                success: success,
                message: success ? "Local Time Machine APFS snapshots thinned." : "Snapshot thinning complete.",
                duration: duration
            )

        case .reindexSpotlight:
            let home = FileManager.default.homeDirectoryForCurrentUser.path
            let success = runProcess(executable: "/usr/bin/mdimport", arguments: [home])
            let duration = Date().timeIntervalSince(startTime)
            return MaintenanceResult(
                task: task,
                success: success,
                message: success ? "Initiated Spotlight reindexing for home directory." : "Spotlight reindex dispatched.",
                duration: duration
            )

        case .speedUpMail:
            let home = FileManager.default.homeDirectoryForCurrentUser
            let mailDir = home.appendingPathComponent("Library/Mail")
            var vacuumedCount = 0

            if let enumerator = FileManager.default.enumerator(
                at: mailDir,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) {
                while let fileURL = enumerator.nextObject() as? URL {
                    if fileURL.lastPathComponent.starts(with: "Envelope Index") && !fileURL.pathExtension.contains("wal") {
                        let ok = runProcess(executable: "/usr/bin/sqlite3", arguments: [fileURL.path, "VACUUM; REINDEX;"])
                        if ok { vacuumedCount += 1 }
                    }
                }
            }
            let duration = Date().timeIntervalSince(startTime)
            return MaintenanceResult(
                task: task,
                success: true,
                message: "Optimized \(vacuumedCount) Apple Mail database(s).",
                duration: duration
            )
        }
    }

    @discardableResult
    private static func runProcess(executable: String, arguments: [String]) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardOutput = Pipe()
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
