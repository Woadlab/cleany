import Foundation

/// Orchestrates multi-category scanning across all registered domain scanners using structured concurrency.
public actor ScanCoordinator {

    private let scanners: [any JunkScanner]

    public init(scanners: [any JunkScanner] = [
        AIScanner(),
        DeveloperScanner(),
        SystemJunkScanner(),
        AppLeftoversScanner(),
        TrashBinsScanner()
    ]) {
        self.scanners = scanners
    }

    /// Runs all scanners concurrently and collects the resulting items by category.
    public func scanAll(
        onProgress: @Sendable @escaping (ScanProgress) -> Void
    ) async -> [JunkCategory: [JunkItem]] {
        var results: [JunkCategory: [JunkItem]] = [:]

        await withTaskGroup(of: (JunkCategory, [JunkItem]).self) { group in
            for scanner in scanners {
                group.addTask {
                    let items = await scanner.scan(onProgress: onProgress)
                    return (scanner.category, items)
                }
            }

            for await (category, items) in group {
                results[category] = items
            }
        }

        return results
    }

    /// Scans a single specific category.
    public func scan(
        category: JunkCategory,
        onProgress: @Sendable @escaping (ScanProgress) -> Void
    ) async -> [JunkItem] {
        guard let scanner = scanners.first(where: { $0.category == category }) else {
            return []
        }
        return await scanner.scan(onProgress: onProgress)
    }
}
