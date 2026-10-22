import SwiftUI
import CleanyCore

public struct DashboardView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    private var categorySizes: [(JunkCategory, UInt64)] {
        JunkCategory.allCases.map { ($0, state.categorySize($0)) }
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 6) {
                    Text("Smart Care")
                        .font(.system(size: 26, weight: .bold))

                    Text(headerSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 18)

                // Central Proportional Arc Gauge
                ScanningGaugeView(
                    isScanning: state.isScanning,
                    hasScanned: state.hasCompletedInitialScan,
                    formattedSize: state.formattedTotalBytes,
                    itemCount: state.totalFoundCount,
                    currentPath: state.scanProgress?.currentPath,
                    categorySizes: categorySizes
                )

                // Action controls
                HStack(spacing: 14) {
                    if !state.hasCompletedInitialScan && !state.isScanning {
                        Button {
                            SoundHaptics.tap()
                            state.startScanAll()
                        } label: {
                            Label("Scan Mac", systemImage: "sparkle.magnifyingglass")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(minWidth: 160, minHeight: 40)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .keyboardShortcut("r", modifiers: .command)
                    } else {
                        Button {
                            SoundHaptics.tap()
                            state.startScanAll()
                        } label: {
                            Label(state.isScanning ? "Scanning..." : "Rescan", systemImage: "arrow.clockwise")
                                .font(.system(size: 13, weight: .medium))
                                .frame(minWidth: 120, minHeight: 36)
                        }
                        .buttonStyle(.bordered)
                        .disabled(state.isScanning || state.isCleaning)
                        .keyboardShortcut("r", modifiers: .command)

                        if state.totalFoundBytes > 0 {
                            Button {
                                SoundHaptics.tap()
                                state.cleanSelected()
                            } label: {
                                Label(
                                    state.isCleaning ? "Cleaning..." : "Clean to Trash",
                                    systemImage: "trash.fill"
                                )
                                .font(.system(size: 13, weight: .semibold))
                                .frame(minWidth: 160, minHeight: 36)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .disabled(state.isScanning || state.isCleaning)
                            .keyboardShortcut(.delete, modifiers: .command)
                        }
                    }
                }

                // Clean Result Notification
                if let result = state.lastCleanResult {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reclaimed \(result.formattedBytes)")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Successfully moved \(result.itemsRemovedCount) items to Trash. Press ⌘Z in Trash to restore if needed.")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.green.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 32)
                }

                // Category Cards Grid with Proportional Share
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 230), spacing: 16)], spacing: 16) {
                    ForEach(JunkCategory.allCases) { category in
                        let items = state.itemsByCategory[category] ?? []
                        let catSize = state.categorySize(category)
                        let percentage = state.totalFoundBytes > 0 ? Double(catSize) / Double(state.totalFoundBytes) : 0.0

                        MetricCardView(
                            category: category,
                            count: items.count,
                            formattedSize: state.categoryFormattedSize(category),
                            percentage: percentage,
                            isSelected: false,
                            onSelect: {
                                state.selectedNav = .category(category)
                            }
                        )
                    }
                }
                .padding(.horizontal, 32)

                // Privacy Trust Bar
                HStack(spacing: 24) {
                    Label("100% Local Execution", systemImage: "shield.lefthalf.filled")
                    Label("Undoable via ⌘Z in Trash", systemImage: "arrow.uturn.backward.circle")
                    Label("Zero Daemons / Zero Tracking", systemImage: "lock.circle")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary.opacity(0.8))
                .padding(.vertical, 6)
                .padding(.bottom, 24)
            }
        }
    }

    private var headerSubtitle: String {
        if state.isScanning {
            return "Deep scanning system directories, developer artifacts & AI tool storage..."
        } else if state.hasCompletedInitialScan {
            if state.totalFoundBytes > 0 {
                return "Found \(state.formattedTotalBytes) across \(state.totalFoundCount) safe-to-remove items."
            } else {
                return "Your Mac is clean and running at peak performance."
            }
        } else {
            return "Scan your Mac locally for AI clutter, developer caches, system junk, and trash."
        }
    }
}
