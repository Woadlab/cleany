import SwiftUI
import AppKit
import CleanyCore

/// Native macOS 27 Space Lens View.
/// Visualizes directory space usage with Liquid Glass platters,
/// modern fluid multi-segmented storage bars, and Finder integration.
public struct SpaceLensView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            // macOS 27 Ambient Fluid Mesh Atmosphere
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Liquid Glass Header Platter
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Space Lens")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Esplora visivamente lo spazio occupato nelle cartelle utente e libreria.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        SoundHaptics.tap()
                        state.scanSpaceLens()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.grid.cross.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(state.isScanningSpace ? "Scansione..." : "Scansiona Spazio")
                                .font(.system(size: 13.5, weight: .bold))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.teal)
                    .disabled(state.isScanningSpace)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 18, tint: Color.teal.opacity(0.08), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                // Main Body
                if state.isScanningSpace {
                    VStack(spacing: 14) {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)

                        Text("Analisi gerarchica del filesystem...")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Calcolo ricorsivo delle dimensioni in corso")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let root = state.spaceRootNode {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            // Root Storage Platter
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.teal.opacity(0.18))
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "internaldrive.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(Color.teal)
                                            .font(.system(size: 16))
                                    }

                                    Text(root.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    Text(root.formattedSize)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }

                                // Fluid Multi-Segmented Storage Bar
                                GeometryReader { geo in
                                    let nonZero = root.children.filter { $0.size > 0 }
                                    let total = Double(root.size > 0 ? root.size : 1)

                                    HStack(spacing: 3) {
                                        ForEach(Array(nonZero.prefix(7).enumerated()), id: \.element.id) { index, child in
                                            let width = max(5, geo.size.width * CGFloat(Double(child.size) / total))
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(colorForIndex(index))
                                                .frame(width: width, height: 10)
                                                .shadow(color: colorForIndex(index).opacity(0.3), radius: 2)
                                        }
                                    }
                                }
                                .frame(height: 10)
                            }
                            .padding(18)
                            .liquidGlass(cornerRadius: 18, tint: Color.teal.opacity(0.06), isInteractive: false)
                            .padding(.horizontal, 24)
                            .padding(.top, 14)

                            // Child Folder Glass Tiles
                            VStack(spacing: 8) {
                                ForEach(Array(root.children.enumerated()), id: \.element.id) { index, child in
                                    spaceNodeRow(node: child, totalSize: root.size, color: colorForIndex(index))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        ContentUnavailableView {
                            Label("Visualizza lo Spazio su Disco", systemImage: "circle.grid.cross")
                        } description: {
                            Text("Avvia una scansione per visualizzare le cartelle più ingombranti della tua cartella utente.")
                        } actions: {
                            Button("Avvia Scansione Spazio") {
                                SoundHaptics.tap()
                                state.scanSpaceLens()
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.teal)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private func spaceNodeRow(node: SpaceNode, totalSize: UInt64, color: Color) -> some View {
        let proportion = totalSize > 0 ? Double(node.size) / Double(totalSize) : 0

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.18))
                    .frame(width: 32, height: 32)

                Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(node.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)

                // Sub-proportion bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.06))
                            .frame(height: 4)

                        Capsule()
                            .fill(color)
                            .frame(width: max(4, geo.size.width * CGFloat(proportion)), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Spacer()

            Text(node.formattedSize)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .monospacedDigit()
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.primary.opacity(0.05))
                .clipShape(Capsule())

            Button {
                SoundHaptics.tap()
                NSWorkspace.shared.selectFile(node.url.path, inFileViewerRootedAtPath: "")
            } label: {
                Image(systemName: "arrow.up.forward.app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Mostra nel Finder")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 12, tint: color.opacity(0.03), isInteractive: true)
    }

    private func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.teal, .blue, .purple, .orange, .pink, .indigo, .mint]
        return palette[idx % palette.count]
    }
}
