import SwiftUI
import CleanyCore

public struct DashboardView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Header
                VStack(spacing: 6) {
                    Text("Smart Care")
                        .font(.system(size: 28, weight: .bold))

                    Text("Scan and safely optimize your Mac in one click.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)

                // Central Gauge
                ScanningGaugeView(
                    isScanning: state.isScanning,
                    formattedSize: state.formattedTotalBytes,
                    itemCount: state.totalFoundCount
                )

                // Action controls
                HStack(spacing: 16) {
                    Button {
                        state.startScanAll()
                    } label: {
                        Label(state.isScanning ? "Scanning..." : "Scan Mac", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .frame(minWidth: 140, minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                    .disabled(state.isScanning || state.isCleaning)

                    if state.totalFoundBytes > 0 {
                        Button {
                            state.cleanSelected()
                        } label: {
                            Label(state.isCleaning ? "Cleaning..." : "Clean to Trash", systemImage: "trash.fill")
                                .font(.headline)
                                .frame(minWidth: 150, minHeight: 38)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .disabled(state.isScanning || state.isCleaning)
                    }
                }

                // Clean Result Notification
                if let result = state.lastCleanResult {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title2)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reclaimed \(result.formattedBytes)")
                                .font(.headline)
                            Text("Successfully moved \(result.itemsRemovedCount) items to Trash.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.green.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 32)
                }

                // Category Cards Grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 16)], spacing: 16) {
                    ForEach(JunkCategory.allCases) { category in
                        let items = state.itemsByCategory[category] ?? []
                        MetricCardView(
                            category: category,
                            count: items.count,
                            formattedSize: state.categoryFormattedSize(category),
                            isSelected: false,
                            onSelect: {
                                state.selectedNav = .category(category)
                            }
                        )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }
}
