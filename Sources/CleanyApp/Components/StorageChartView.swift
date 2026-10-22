import SwiftUI
import Charts
import CleanyCore

public struct CategoryChartData: Identifiable {
    public let id: JunkCategory
    public let category: JunkCategory
    public let size: UInt64
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }

    public init(category: JunkCategory, size: UInt64) {
        self.id = category
        self.category = category
        self.size = size
    }
}

/// Native macOS data visualization using Swift Charts.
/// Implements a responsive Donut Chart (SectorMark) respecting Apple HIG,
/// San Francisco typography, and dynamic system appearance.
public struct StorageChartView: View {
    public let data: [CategoryChartData]
    public let totalBytes: UInt64
    public let totalCount: Int
    public let isScanning: Bool
    public let currentScanningPath: String?

    public init(
        data: [CategoryChartData],
        totalBytes: UInt64,
        totalCount: Int,
        isScanning: Bool = false,
        currentScanningPath: String? = nil
    ) {
        self.data = data
        self.totalBytes = totalBytes
        self.totalCount = totalCount
        self.isScanning = isScanning
        self.currentScanningPath = currentScanningPath
    }

    private var nonZeroData: [CategoryChartData] {
        data.filter { $0.size > 0 }
    }

    private var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if nonZeroData.isEmpty {
                    // Empty or Initial state circular track
                    Circle()
                        .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 22)
                        .frame(width: 220, height: 220)
                } else {
                    // Native Swift Charts Donut Chart
                    Chart(nonZeroData) { item in
                        SectorMark(
                            angle: .value("Dimensione", Double(item.size)),
                            innerRadius: .ratio(0.72),
                            angularInset: 1.5
                        )
                        .cornerRadius(3)
                        .foregroundStyle(by: .value("Categoria", item.category.title))
                    }
                    .chartLegend(.hidden)
                    .chartForegroundStyleScale([
                        JunkCategory.aiClutter.title: Color.purple,
                        JunkCategory.developerJunk.title: Color.blue,
                        JunkCategory.systemJunk.title: Color.teal,
                        JunkCategory.appLeftovers.title: Color.orange,
                        JunkCategory.trashBins.title: Color.red
                    ])
                    .frame(width: 230, height: 230)
                }

                // Center Information Display
                VStack(spacing: 4) {
                    if isScanning {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color.accentColor)
                            .symbolEffect(.pulse)

                        Text("Scansione in corso")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Analisi file locali...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if totalBytes > 0 {
                        Text(formattedTotal)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("\(totalCount) elementi trovati")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundStyle(Color.accentColor)

                        Text("Mac Ottimizzato")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Nessun elemento da pulire")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            }

            // Real-Time Scanning Path Ticker
            if isScanning, let path = currentScanningPath, !path.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 12)
    }
}
