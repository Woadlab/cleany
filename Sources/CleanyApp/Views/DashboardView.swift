import SwiftUI
import CleanyCore

/// Native Apple HIG Dashboard View.
/// Focuses on content deference, clean San Francisco typography, standard system controls,
/// and Swift Charts data visualization without artificial glow or web-like artifacts.
public struct DashboardView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    private var chartData: [CategoryChartData] {
        JunkCategory.allCases.map { category in
            CategoryChartData(category: category, size: state.categorySize(category))
        }
    }

    private var headerSubtitle: String {
        if state.isScanning {
            return "Analisi locale dei percorsi di cache, log e residui in corso..."
        } else if state.isCleaning {
            return "Spostamento sicuro nel Cestino di macOS..."
        } else if state.hasCompletedInitialScan {
            if state.totalFoundBytes > 0 {
                return "Rilevati elementi non necessari pronti per essere rimossi in sicurezza."
            } else {
                return "Il tuo Mac è pulito e ottimizzato. Nessun elemento trovato."
            }
        } else {
            return "Scansiona il disco per individuare cache, log e residui software in modo 100% locale."
        }
    }

    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Section Header
                VStack(spacing: 6) {
                    Text("Smart Care")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Swift Charts Donut Chart Hero
                StorageChartView(
                    data: chartData,
                    totalBytes: state.totalFoundBytes,
                    totalCount: state.totalFoundCount,
                    isScanning: state.isScanning,
                    currentScanningPath: state.scanProgress?.currentPath
                )

                // Native Action Controls
                actionButtons
                    .padding(.top, 4)

                // Clean Native Grouped Categories Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Riepilogo Categorie")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 4)

                    VStack(spacing: 0) {
                        ForEach(Array(JunkCategory.allCases.enumerated()), id: \.element.id) { index, category in
                            categoryRow(category: category)

                            if index < JunkCategory.allCases.count - 1 {
                                Divider()
                                    .padding(.leading, 48)
                            }
                        }
                    }
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: 720)
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if state.isScanning {
                Button {
                    // Scanning active
                } label: {
                    Label("Scansione in corso...", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(true)
            } else if state.isCleaning {
                Button {
                    // Cleaning active
                } label: {
                    Label("Pulizia in corso...", systemImage: "trash")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(true)
            } else if state.hasCompletedInitialScan && state.totalFoundBytes > 0 {
                Button {
                    SoundHaptics.clean()
                    state.cleanSelected()
                } label: {
                    Label("Sposta nel Cestino", systemImage: "trash.fill")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(Capsule())

                Button {
                    SoundHaptics.tap()
                    state.startScanAll()
                } label: {
                    Label("Riscansiona", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .clipShape(Capsule())
            } else {
                Button {
                    SoundHaptics.tap()
                    state.startScanAll()
                } label: {
                    Label("Scansiona Mac", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private func categoryRow(category: JunkCategory) -> some View {
        let size = state.categorySize(category)
        let count = state.itemsByCategory[category]?.filter { $0.isSelected }.count ?? 0

        Button {
            SoundHaptics.tap()
            state.selectedNav = .category(category)
        } label: {
            HStack(spacing: 14) {
                // SF Symbol with native hierarchical rendering
                Image(systemName: category.systemImage)
                    .font(.system(size: 17, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(colorForCategory(category))
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(category.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)

                        if let badge = category.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    Text(category.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if size > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(state.categoryFormattedSize(category))
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text("\(count) elementi")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else if state.hasCompletedInitialScan {
                    Text("Pulito")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.forward")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func colorForCategory(_ category: JunkCategory) -> Color {
        switch category {
        case .aiClutter: return .purple
        case .developerJunk: return .blue
        case .systemJunk: return .teal
        case .appLeftovers: return .orange
        case .trashBins: return .red
        }
    }
}
