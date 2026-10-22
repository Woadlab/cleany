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
        ZStack {
            // Ethereal atmospheric background
            AtmosphericBackgroundView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Top App Header
                    VStack(spacing: 4) {
                        Text("Smart Care")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(headerSubtitle)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 14)

                    // CleanMyMac 5-Grade Hero Glass Lens
                    ScanningGaugeView(
                        isScanning: state.isScanning,
                        hasScanned: state.hasCompletedInitialScan,
                        formattedSize: state.formattedTotalBytes,
                        itemCount: state.totalFoundCount,
                        currentPath: state.scanProgress?.currentPath,
                        categorySizes: categorySizes
                    )

                    // Island CTA Action Button (Button-in-Button Architecture)
                    HStack(spacing: 14) {
                        if !state.hasCompletedInitialScan && !state.isScanning {
                            // Primary Start Scan Island
                            Button {
                                SoundHaptics.tap()
                                state.startScanAll()
                            } label: {
                                HStack(spacing: 12) {
                                    Text("Scan Mac")
                                        .font(.system(size: 14.5, weight: .bold))
                                        .foregroundStyle(.white)

                                    // Nested Bezel Trailing Icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.20))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: "sparkle.magnifyingglass")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.leading, 24)
                                .padding(.trailing, 8)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.15, green: 0.50, blue: 1.0),
                                                    Color(red: 0.05, green: 0.70, blue: 0.95)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                                )
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 4)
                            }
                            .buttonStyle(PressableButtonStyle())
                            .keyboardShortcut("r", modifiers: .command)

                        } else {
                            // Secondary Rescan Pill
                            Button {
                                SoundHaptics.tap()
                                state.startScanAll()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(state.isScanning ? "Scanning..." : "Rescan")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                            .disabled(state.isScanning || state.isCleaning)
                            .keyboardShortcut("r", modifiers: .command)

                            // Primary Clean Island Button
                            if state.totalFoundBytes > 0 {
                                Button {
                                    SoundHaptics.tap()
                                    state.cleanSelected()
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(state.isCleaning ? "Cleaning..." : "Clean to Trash")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)

                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.20))
                                                .frame(width: 28, height: 28)

                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.leading, 22)
                                    .padding(.trailing, 8)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.15, green: 0.50, blue: 1.0),
                                                        Color(red: 0.05, green: 0.70, blue: 0.95)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                                    .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 4)
                                }
                                .buttonStyle(PressableButtonStyle())
                                .disabled(state.isScanning || state.isCleaning)
                                .keyboardShortcut(.delete, modifiers: .command)
                            }
                        }
                    }

                    // Clean Completion Notification Banner
                    if let result = state.lastCleanResult {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.green)

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Reclaimed \(result.formattedBytes)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)

                                Text("Moved \(result.itemsRemovedCount) items to Trash. Press ⌘Z in Trash to restore if needed.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.green.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 28)
                    }

                    // Asymmetrical Bento Grid (3 Top + 2 Bottom = All 5 Fit on Screen)
                    VStack(spacing: 12) {
                        // Top Row: 3 Core Scanners
                        HStack(spacing: 12) {
                            bentoCard(for: .aiClutter)
                            bentoCard(for: .developerJunk)
                            bentoCard(for: .systemJunk)
                        }

                        // Bottom Row: 2 Major Storage Hogs
                        HStack(spacing: 12) {
                            bentoCard(for: .appLeftovers)
                            bentoCard(for: .trashBins)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private func bentoCard(for category: JunkCategory) -> some View {
        let items = state.itemsByCategory[category] ?? []
        let catSize = state.categorySize(category)
        let percentage = state.totalFoundBytes > 0 ? Double(catSize) / Double(state.totalFoundBytes) : 0.0

        return MetricCardView(
            category: category,
            count: items.count,
            formattedSize: state.categoryFormattedSize(category),
            percentage: percentage,
            isSelected: false,
            onSelect: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    state.selectedNav = .category(category)
                }
            }
        )
    }

    private var headerSubtitle: String {
        if state.isScanning {
            return "Deep-scanning AI models, caches, and storage artifacts..."
        } else if state.hasCompletedInitialScan {
            if state.totalFoundBytes > 0 {
                return "Discovered \(state.formattedTotalBytes) across \(state.totalFoundCount) safe-to-clean items."
            } else {
                return "Your Mac is running at peak condition."
            }
        } else {
            return "100% Local • Zero Telemetry • Safe macOS Trash Defaults"
        }
    }
}

/// Tactile button press feedback style conforming to Apple Design Guidelines
public struct PressableButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
