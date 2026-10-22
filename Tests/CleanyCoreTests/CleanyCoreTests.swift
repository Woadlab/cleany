import Testing
@testable import CleanyCore
import Foundation

@Suite("CleanyCore Domain Tests")
struct CleanyCoreTests {

    @Test("Category metadata attributes")
    func categoryAttributes() {
        #expect(JunkCategory.aiClutter.title == "Cache & Modelli AI")
        #expect(JunkCategory.aiClutter.badge == "AI")
        #expect(JunkCategory.developerJunk.title == "Residui Sviluppo")
        #expect(JunkCategory.allCases.count == 5)
    }

    @Test("Path safety validator invariants")
    func fileUtilitiesSafetyChecks() {
        let root = URL(fileURLWithPath: "/")
        #expect(!FileUtilities.isSafeToDelete(url: root))

        let system = URL(fileURLWithPath: "/System/Library/CoreServices")
        #expect(!FileUtilities.isSafeToDelete(url: system))

        let usrBin = URL(fileURLWithPath: "/usr/bin/bash")
        #expect(!FileUtilities.isSafeToDelete(url: usrBin))

        let home = FileManager.default.homeDirectoryForCurrentUser
        let documents = home.appendingPathComponent("Documents")
        #expect(!FileUtilities.isSafeToDelete(url: documents))

        let tempCache = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test_cache")
        #expect(FileUtilities.isSafeToDelete(url: tempCache))
    }

    @Test("Byte count size formatting")
    func byteFormatting() {
        let item = JunkItem(
            url: URL(fileURLWithPath: "/tmp/fake.tmp"),
            displayName: "Fake Temp",
            subtitle: "/tmp",
            size: 1024 * 1024 * 50, // 50 MB
            category: .systemJunk,
            subcategory: "Temp",
            isDirectory: false,
            explanation: "Testing"
        )

        #expect(item.formattedSize.contains("50") || item.formattedSize.contains("52"))
    }

    @Test("AI Scanner initializes and scans without crashing")
    func aiScannerInstantiation() async {
        let scanner = AIScanner()
        #expect(scanner.category == .aiClutter)
        let items = await scanner.scan { _ in }
        #expect(items.count >= 0)
    }
}
