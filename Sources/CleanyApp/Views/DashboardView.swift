import SwiftUI
import CleanyCore

/// Native macOS 27 Dashboard View.
/// Features a spacious, breathing 2-column Liquid Glass Bento Grid,
/// San Francisco Rounded typography without hyphenations, and single-source actions.
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
            return "Spostamento sicuro nel Cestino di macOS in corso..."
        } else if state.hasCompletedInitialScan {
            if state.totalFoundBytes > 0 {
                return "Rilevati elementi non necessari pronti per essere rimossi in totale sicurezza."
            } else {
                return "Il tuo Mac è completamente ottimizzato. Nessun residuo rilevato."
            }
        } else {
            return "Scansiona il disco per individuare cache, log e residui software in modo 100% locale."
        }
    }

    public var body: some View {
        ZStack {
            // macOS 27 Ambient Fluid Mesh Atmosphere
            LiquidGlassBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    // Title Header
                    VStack(spacing: 6) {
                        Text("Smart Care")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(headerSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // Hero Liquid Glass Storage Platter
                    StorageChartView(
                        data: chartData,
                        totalBytes: state.totalFoundBytes,
                        totalCount: state.totalFoundCount,
                        isScanning: state.isScanning,
                        isCleaning: state.isCleaning,
                        hasCompletedInitialScan: state.hasCompletedInitialScan,
                        currentScanningPath: state.scanProgress?.currentPath,
                        onPrimaryAction: {
                            if state.hasCompletedInitialScan && state.totalFoundBytes > 0 {
                                state.cleanSelected()
                            } else {
                                state.startScanAll()
                            }
                        },
                        onSecondaryAction: {
                            state.startScanAll()
                        }
                    )

                    // Bento Grid of Liquid Glass Category Platters (Spacious 2-Column Grid)
                    VStack(spacing: 16) {
                        HStack {
                            Text("Aree di Pulizia")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Spacer()

                            Text("Clicca su una sezione per gestirne i file")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 4)

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 18),
                                GridItem(.flexible(), spacing: 18)
                            ],
                            spacing: 18
                        ) {
                            categoryCard(category: .aiClutter)
                            categoryCard(category: .developerJunk)
                            categoryCard(category: .systemJunk)
                            categoryCard(category: .appLeftovers)
                            categoryCard(category: .trashBins)
                        }
                    }
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 40)
                .frame(maxWidth: 960)
            }
        }
    }

    @ViewBuilder
    private func categoryCard(category: JunkCategory) -> some View {
        let size = state.categorySize(category)
        let total = Double(state.totalFoundBytes > 0 ? state.totalFoundBytes : 1)
        let count = state.itemsByCategory[category]?.filter { $0.isSelected }.count ?? 0
        let percentage = Double(size) / total

        LiquidCategoryCardView(
            category: category,
            count: count,
            size: size,
            formattedSize: state.categoryFormattedSize(category),
            percentage: percentage,
            isScanning: state.isScanning,
            onSelect: {
                state.selectedNav = .category(category)
            }
        )
    }
}
