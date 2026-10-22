import Foundation

/// Protocol that every modular domain scanner conforms to.
public protocol JunkScanner: Sendable {
    var category: JunkCategory { get }
    func scan(onProgress: @Sendable @escaping (ScanProgress) -> Void) async -> [JunkItem]
}
