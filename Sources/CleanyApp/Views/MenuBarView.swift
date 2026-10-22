import SwiftUI
import AppKit
import CleanyCore

/// Native macOS 27 Menu Bar Extra View.
/// Compact, fluid Liquid Glass popover providing at-a-glance Mac health status,
/// quick Smart Care actions, live Trash / SSD telemetry, and deep-links to the main window.
public struct MenuBarView: View {
    @ObservedObject var state: AppState
    @Environment(\.openWindow) private var openWindow

    public init(state: AppState) {
        self.state = state
    }

    private var diskCapacity: (free: String, total: String, usedRatio: Double) {
        if let values = try? URL(fileURLWithPath: "/").resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]),
           let free = values.volumeAvailableCapacity,
           let total = values.volumeTotalCapacity, total > 0 {
            let freeStr = ByteCountFormatter.string(fromByteCount: Int64(free), countStyle: .file)
            let totalStr = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)
            let used = Double(max(0, total - free))
            let ratio = min(1.0, max(0.0, used / Double(total)))
            return (freeStr, totalStr, ratio)
        }
        return ("--", "--", 0.0)
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header: Brand & Live Status
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.accentColor.opacity(0.4), lineWidth: 1))

                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }

                Text("Cleany")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                if state.isScanning {
                    HStack(spacing: 5) {
                        ProgressView().controlSize(.mini)
                        Text("Scansione...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                } else if state.isCleaning {
                    HStack(spacing: 5) {
                        ProgressView().controlSize(.mini)
                        Text("Pulizia...")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Capsule())
                } else if state.totalFoundBytes > 0 {
                    Text("\(state.formattedTotalBytes) trovati")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.15))
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("Protetto")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.12))
                    .clipShape(Capsule())
                }
            }

            // Smart Care Quick Action Platter
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.14))
                            .frame(width: 38, height: 38)

                        Image(systemName: state.totalFoundBytes > 0 ? "trash.fill" : "shield.checkerboard")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(state.totalFoundBytes > 0 ? Color.orange : Color.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Care")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        if state.totalFoundBytes > 0 {
                            Text("\(state.formattedTotalBytes) di file non necessari")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else if state.hasCompletedInitialScan {
                            Text("Il Mac è perfettamente ottimizzato")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        } else {
                            Text("Avvia una scansione locale veloce")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()
                }

                // Action Button
                if state.isScanning || state.isCleaning {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text(state.isScanning ? "Scansione disco..." : "Pulizia in corso...")
                            .font(.system(size: 12.5, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
                } else if state.totalFoundBytes > 0 {
                    Button {
                        SoundHaptics.clean()
                        state.cleanSelected()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("Sposta nel Cestino (\(state.formattedTotalBytes))")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                    }
                    .cleanyGlassProminent(tint: .red)
                    .clipShape(Capsule())
                } else {
                    Button {
                        state.startScanAll()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle.magnifyingglass")
                                .font(.system(size: 12, weight: .bold))
                            Text("Avvia Scansione")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                    }
                    .cleanyGlassProminent(tint: Color.accentColor)
                    .clipShape(Capsule())
                }
            }
            .padding(12)
            .liquidGlass(cornerRadius: 16, tint: Color.accentColor.opacity(0.05), isInteractive: false)

            // At-A-Glance System Telemetry Card
            VStack(spacing: 10) {
                // Trash Glance Row
                HStack(spacing: 10) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    Text("Cestino di macOS")
                        .font(.caption)
                        .foregroundStyle(.primary)

                    Spacer()

                    let trashSize = state.categoryFormattedSize(.trashBins)
                    Text(trashSize)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Button("Svuota") {
                        SoundHaptics.clean()
                        state.cleanSelected(category: .trashBins)
                    }
                    .cleanyGlass()
                    .clipShape(Capsule())
                    .controlSize(.mini)
                    .disabled(state.categorySize(.trashBins) == 0 || state.isCleaning)
                }

                Divider().opacity(0.4)

                // Disk Capacity Row
                VStack(spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "internaldrive")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .frame(width: 20)

                        Text("Macintosh HD")
                            .font(.caption)
                            .foregroundStyle(.primary)

                        Spacer()

                        Text("\(diskCapacity.free) liberi")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }

                    // Mini System Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.primary.opacity(0.08))
                                .frame(height: 5)

                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.teal, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(4, geo.size.width * CGFloat(diskCapacity.usedRatio)), height: 5)
                        }
                    }
                    .frame(height: 5)
                }
            }
            .padding(12)
            .liquidGlass(cornerRadius: 16, tint: Color.primary.opacity(0.03), isInteractive: false)

            // Deep Navigation Links to Main Window
            HStack(spacing: 8) {
                Button {
                    state.selectedNav = .spaceLens
                    openMainWindow()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.grid.cross")
                            .font(.system(size: 11))
                        Text("Lente Spazio")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .cleanyGlass()
                .clipShape(Capsule())

                Button {
                    state.selectedNav = .maintenance
                    openMainWindow()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 11))
                        Text("Manutenzione")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                }
                .cleanyGlass()
                .clipShape(Capsule())
            }

            Divider().opacity(0.5)

            // Footer Controls
            HStack {
                Button {
                    openMainWindow()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 12))
                        Text("Apri Cleany")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)

                Spacer()

                Button("Esci da Cleany") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(14)
        .frame(width: 320)
    }

    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let window = NSApp.windows.first(where: { $0.canBecomeMain && ($0.title == "Cleany" || $0.identifier?.rawValue == "main") }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            openWindow(id: "main")
        }
    }
}
