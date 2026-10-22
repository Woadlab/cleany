import SwiftUI
import Combine
import CleanyCore

public enum NavigationItem: Hashable, Sendable {
    case smartCare
    case category(JunkCategory)
    case maintenance
    case spaceLens
}

@MainActor
public final class AppState: ObservableObject {
    @Published public var selectedNav: NavigationItem = .smartCare

    @Published public var hasCompletedInitialScan: Bool = false
    @Published public var isScanning: Bool = false
    @Published public var scanProgress: ScanProgress? = nil

    @Published public var isCleaning: Bool = false
    @Published public var lastCleanResult: CleanResult? = nil

    @Published public var itemsByCategory: [JunkCategory: [JunkItem]] = [:]

    // Space Lens
    @Published public var spaceRootNode: SpaceNode? = nil
    @Published public var isScanningSpace: Bool = false

    // Maintenance
    @Published public var runningTasks: Set<MaintenanceTask> = []
    @Published public var maintenanceResults: [MaintenanceTask: MaintenanceRunner.MaintenanceResult] = [:]

    private let coordinator = ScanCoordinator()

    public init() {}

    public var totalFoundBytes: UInt64 {
        itemsByCategory.values.flatMap { $0 }.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }

    public var totalFoundCount: Int {
        itemsByCategory.values.flatMap { $0 }.filter { $0.isSelected }.count
    }

    public var formattedTotalBytes: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalFoundBytes), countStyle: .file)
    }

    public func categorySize(_ category: JunkCategory) -> UInt64 {
        itemsByCategory[category]?.filter { $0.isSelected }.reduce(0) { $0 + $1.size } ?? 0
    }

    public func categoryFormattedSize(_ category: JunkCategory) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(categorySize(category)), countStyle: .file)
    }

    public func startScanAll() {
        guard !isScanning else { return }
        isScanning = true
        lastCleanResult = nil

        Task { [weak self] in
            guard let self else { return }
            let results = await self.coordinator.scanAll { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.scanProgress = progress
                }
            }

            self.itemsByCategory = results
            self.hasCompletedInitialScan = true
            self.isScanning = false
            self.scanProgress = nil
        }
    }

    public func startScan(category: JunkCategory) {
        guard !isScanning else { return }
        isScanning = true

        Task { [weak self] in
            guard let self else { return }
            let items = await self.coordinator.scan(category: category) { [weak self] progress in
                Task { @MainActor [weak self] in
                    self?.scanProgress = progress
                }
            }

            self.itemsByCategory[category] = items
            self.isScanning = false
            self.scanProgress = nil
        }
    }

    public func cleanSelected(category: JunkCategory? = nil) {
        guard !isCleaning else { return }
        isCleaning = true

        let itemsToClean: [JunkItem]
        if let category = category {
            itemsToClean = itemsByCategory[category]?.filter { $0.isSelected } ?? []
        } else {
            itemsToClean = itemsByCategory.values.flatMap { $0 }.filter { $0.isSelected }
        }

        Task {
            let result = await SafeDeletionManager.delete(items: itemsToClean, mode: .moveToTrash)
            self.lastCleanResult = result

            let cleanedIDs = Set(itemsToClean.map { $0.id })
            for (cat, items) in self.itemsByCategory {
                self.itemsByCategory[cat] = items.filter { !cleanedIDs.contains($0.id) }
            }

            self.isCleaning = false
        }
    }

    public func toggleItemSelection(id: UUID) {
        for (cat, items) in itemsByCategory {
            if let idx = items.firstIndex(where: { $0.id == id }) {
                itemsByCategory[cat]?[idx].isSelected.toggle()
                break
            }
        }
    }

    public func selectAll(in category: JunkCategory, isSelected: Bool) {
        guard let items = itemsByCategory[category] else { return }
        itemsByCategory[category] = items.map {
            var copy = $0
            copy.isSelected = isSelected
            return copy
        }
    }

    public func runMaintenanceTask(_ task: MaintenanceTask) {
        guard !runningTasks.contains(task) else { return }
        runningTasks.insert(task)

        Task {
            let result = await MaintenanceRunner.run(task: task)
            self.maintenanceResults[task] = result
            self.runningTasks.remove(task)
        }
    }

    public func scanSpaceLens(directory: URL? = nil) {
        guard !isScanningSpace else { return }
        isScanningSpace = true

        let targetDir = directory ?? FileManager.default.homeDirectoryForCurrentUser

        Task {
            let root = await SpaceLensScanner.scan(directory: targetDir, maxDepth: 2)
            self.spaceRootNode = root
            self.isScanningSpace = false
        }
    }
}
