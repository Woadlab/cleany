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

/// Native macOS 27 Hero Liquid Glass Storage Visualization Platter.
/// Combines Swift Charts Donut Chart (`SectorMark`), dynamic glass lens core,
/// and live telemetry ticker.
public struct StorageChartView: View {
    public let data: [CategoryChartData]
    public let totalBytes: UInt64
    public let totalCount: Int
    public let isScanning: Bool
    public let isCleaning: Bool
    public let hasCompletedInitialScan: Bool
    public let currentScanningPath: String?
    public let onPrimaryAction: () -> Void
    public let onSecondaryAction: () -> Void

    public init(
        data: [CategoryChartData],
        totalBytes: UInt64,
        totalCount: Int,
        isScanning: Bool = false,
        isCleaning: Bool = false,
        hasCompletedInitialScan: Bool = false,
        currentScanningPath: String? = nil,
        onPrimaryAction: @escaping () -> Void = {},
        onSecondaryAction: @escaping () -> Void = {}
    ) {
        self.data = data
        self.totalBytes = totalBytes
        self.totalCount = totalCount
        self.isScanning = isScanning
        self.isCleaning = isCleaning
        self.hasCompletedInitialScan = hasCompletedInitialScan
        self.currentScanningPath = currentScanningPath
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    private var nonZeroData: [CategoryChartData] {
        data.filter { $0.size > 0 }
    }

    private var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: Int64(totalBytes), countStyle: .file)
    }

    public var body: some View {
        VStack(spacing: 24) {
            // Interactive Glass Donut Chart & Core
            ZStack {
                if nonZeroData.isEmpty {
                    // Empty / Clean circular glass track
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 24)
                        .frame(width: 240, height: 240)
                } else {
                    // Swift Charts Donut Chart
                    Chart(nonZeroData) { item in
                        SectorMark(
                            angle: .value("Dimensione", Double(item.size)),
                            innerRadius: .ratio(0.72),
                            angularInset: 2.0
                        )
                        .cornerRadius(4)
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
                    .frame(width: 250, height: 250)
                }

                // Center Glass Lens Core
                VStack(spacing: 4) {
                    if isScanning {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.accentColor)
                            .symbolEffect(.pulse)

                        Text("Scansione...")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Analisi disco locale")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if isCleaning {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.red)
                            .symbolEffect(.pulse)

                        Text("Pulizia...")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Spostamento nel Cestino")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if totalBytes > 0 {
                        Text(formattedTotal)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("\(totalCount) elementi trovati")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    } else if hasCompletedInitialScan {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.green)

                        Text("Mac Ottimizzato")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Zero file spazzatura")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.accentColor)

                        Text("Pronto per la Scansione")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("100% Locale e Privato")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(width: 170, height: 170)
                .background(Circle().fill(.ultraThinMaterial.opacity(0.4)))
            }

            // Real-Time Scanning File Telemetry Pill
            if isScanning, let path = currentScanningPath, !path.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)

                    Text(path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 420)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(cornerRadius: 16, tint: Color.accentColor.opacity(0.12), isInteractive: false)
            }

            // Floating Liquid Glass Control Dock
            HStack(spacing: 14) {
                if isScanning || isCleaning {
                    Button {
                        // In progress
                    } label: {
                        HStack(spacing: 8) {
                            ProgressView()
                                .controlSize(.small)
                            Text(isScanning ? "Scansione in corso..." : "Pulizia in corso...")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .cleanyGlass()
                    .clipShape(Capsule())
                    .disabled(true)
                } else if hasCompletedInitialScan && totalBytes > 0 {
                    // Primary Clean Button with native .buttonStyle(.glassProminent)
                    Button {
                        SoundHaptics.clean()
                        onPrimaryAction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Sposta nel Cestino (\(formattedTotal))")
                                .font(.system(size: 14.5, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .cleanyGlassProminent(tint: .red)
                    .clipShape(Capsule())

                    // Secondary Rescan Button
                    Button {
                        onSecondaryAction()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Riscansiona")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                    }
                    .cleanyGlass()
                    .clipShape(Capsule())
                } else {
                    // Primary Scan Mac Button with native .buttonStyle(.glassProminent)
                    Button {
                        onPrimaryAction()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .font(.system(size: 15, weight: .bold))
                            Text("Scansiona Mac")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .padding(.horizontal, 28)
                        .padding(.vertical, 11)
                    }
                    .cleanyGlassProminent(tint: Color.accentColor)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 26, tint: Color.accentColor.opacity(0.04), isInteractive: false)
    }
}
