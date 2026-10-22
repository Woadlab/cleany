import Foundation
import CleanyCore

@main
struct CleanyCLI {
    static func main() async {
        let args = CommandLine.arguments

        if args.count < 2 || args.contains("-h") || args.contains("--help") {
            printHelp()
            return
        }

        let command = args[1].lowercased()

        switch command {
        case "scan":
            await handleScan(args: Array(args.dropFirst(2)))
        case "clean":
            await handleClean(args: Array(args.dropFirst(2)))
        case "maintenance":
            await handleMaintenance(args: Array(args.dropFirst(2)))
        case "version", "-v", "--version":
            print("Cleany v1.0.0 (100% Local & Open Source macOS Cleaner)")
        default:
            print("Unknown command: \(command)")
            printHelp()
        }
    }

    static func printHelp() {
        print("""
        Cleany — 100% Local & Privacy-by-Design macOS Cleaner
        
        USAGE:
            cleany <command> [options]

        COMMANDS:
            scan                Scan for reclaimable disk space across all categories
            clean               Safely move discovered junk items to macOS Trash
            maintenance         Run local macOS system maintenance tasks
            version             Display current version

        OPTIONS:
            --category <name>   Filter by category (ai, dev, system, leftovers, trash)
            --permanent         Permanently remove files instead of moving to Trash
            --dry-run           Preview files that would be removed without deleting
            -h, --help          Show help information

        EXAMPLES:
            cleany scan
            cleany scan --category ai
            cleany clean --category ai
            cleany maintenance run flushDNS
        """)
    }

    static func handleScan(args: [String]) async {
        print("🔍 Starting Cleany local scan...")
        let coordinator = ScanCoordinator()

        let categoryFilter: JunkCategory? = {
            if let idx = args.firstIndex(of: "--category"), idx + 1 < args.count {
                return parseCategory(args[idx + 1])
            }
            return nil
        }()

        var totalBytes: UInt64 = 0
        var totalItems = 0

        if let category = categoryFilter {
            print("Target category: \(category.title)\n")
            let items = await coordinator.scan(category: category) { progress in
                print("\rScanning: \(progress.currentPath.suffix(60))", terminator: "")
                fflush(stdout)
            }
            print("\r" + String(repeating: " ", count: 80) + "\r")
            printResults(category: category, items: items)
            totalBytes += items.reduce(0) { $0 + $1.size }
            totalItems += items.count
        } else {
            let results = await coordinator.scanAll { progress in
                print("\rScanning: \(progress.currentPath.suffix(60))", terminator: "")
                fflush(stdout)
            }
            print("\r" + String(repeating: " ", count: 80) + "\r")

            for category in JunkCategory.allCases {
                let items = results[category] ?? []
                printResults(category: category, items: items)
                totalBytes += items.reduce(0) { $0 + $1.size }
                totalItems += items.count
            }
        }

        let formattedTotal = ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)
        print("\n═══════════════════════════════════════════════════════════")
        print("  TOTAL RECLAIMABLE SPACE: \(formattedTotal) across \(totalItems) item(s)")
        print("═══════════════════════════════════════════════════════════")
    }

    static func handleClean(args: [String]) async {
        let isDryRun = args.contains("--dry-run")
        let isPermanent = args.contains("--permanent")

        let categoryFilter: JunkCategory? = {
            if let idx = args.firstIndex(of: "--category"), idx + 1 < args.count {
                return parseCategory(args[idx + 1])
            }
            return nil
        }()

        print("🧹 Scanning targets for cleaning...")
        let coordinator = ScanCoordinator()

        var allItems: [JunkItem] = []
        if let category = categoryFilter {
            allItems = await coordinator.scan(category: category) { _ in }
        } else {
            let results = await coordinator.scanAll { _ in }
            allItems = results.values.flatMap { $0 }
        }

        guard !allItems.isEmpty else {
            print("✨ Nothing to clean! Your Mac is already spotless.")
            return
        }

        let totalBytes = allItems.reduce(0) { $0 + $1.size }
        let formattedTotal = ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)

        if isDryRun {
            print("\n[DRY RUN] Would remove \(allItems.count) item(s) (\(formattedTotal)):")
            for item in allItems {
                print(" - [\(item.category.title)] \(item.displayName) (\(item.formattedSize))")
            }
            return
        }

        let mode: SafeDeletionManager.DeletionMode = isPermanent ? .permanentDelete : .moveToTrash
        let modeDesc = isPermanent ? "permanently delete" : "move to Trash"
        print("Preparing to \(modeDesc) \(allItems.count) items (\(formattedTotal))...")

        let result = await SafeDeletionManager.delete(items: allItems, mode: mode)
        print("\n✅ Clean complete!")
        print("  Reclaimed: \(result.formattedBytes)")
        print("  Items removed: \(result.itemsRemovedCount)")
        if !result.errors.isEmpty {
            print("  Warnings/Errors (\(result.errors.count)):")
            for err in result.errors {
                print("   ⚠️  \(err)")
            }
        }
    }

    static func handleMaintenance(args: [String]) async {
        if args.isEmpty || args.contains("list") {
            print("Available maintenance tasks:")
            for task in MaintenanceTask.allCases {
                print(" - \(task.rawValue): \(task.title) (\(task.taskDescription))")
            }
            return
        }

        if args.first == "run", args.count > 1 {
            let taskName = args[1]
            guard let task = MaintenanceTask(rawValue: taskName) else {
                print("Unknown task: \(taskName)")
                return
            }

            print("⚙️  Running maintenance task: \(task.title)...")
            let result = await MaintenanceRunner.run(task: task)
            if result.success {
                print("✅ Done in \(String(format: "%.2f", result.duration))s: \(result.message)")
            } else {
                print("❌ Failed: \(result.message)")
            }
        }
    }

    private static func printResults(category: JunkCategory, items: [JunkItem]) {
        let size = items.reduce(0) { $0 + $1.size }
        let formattedSize = ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
        print("┌── \(category.title) (\(formattedSize) in \(items.count) items)")
        for item in items.prefix(8) {
            print("│   • \(item.displayName) [\(item.formattedSize)]")
        }
        if items.count > 8 {
            print("│   ... and \(items.count - 8) more")
        }
        print("└──")
    }

    private static func parseCategory(_ name: String) -> JunkCategory? {
        switch name.lowercased() {
        case "ai", "aiclutter", "ai-clutter":
            return .aiClutter
        case "dev", "developer", "developerjunk":
            return .developerJunk
        case "system", "systemjunk":
            return .systemJunk
        case "leftovers", "appleftovers":
            return .appLeftovers
        case "trash", "trashbins":
            return .trashBins
        default:
            return nil
        }
    }
}
