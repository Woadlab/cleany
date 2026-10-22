import SwiftUI
import AppKit
import Charts
import CleanyCore

/// Native Apple HIG Space Lens View.
/// Visualizes local disk and library directory space usage with native Swift Charts and Finder integration.
public struct SpaceLensView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space Lens")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Esplora lo spazio occupato nelle cartelle utente e libreria.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    SoundHaptics.tap()
                    state.scanSpaceLens()
                } label: {
                    Label(state.isScanningSpace ? "Scansione..." : "Scansiona Spazio", systemImage: "circle.grid.cross")
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.isScanningSpace)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Main Body
            if state.isScanningSpace {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)

                    Text("Analisi della gerarchia delle cartelle...")
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
                        // Root Overview Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "internaldrive.fill")
                                    .font(.title3)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(Color.accentColor)

                                Text(root.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Text(root.formattedSize)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }

                            // Native Segmented Progress Bar
                            GeometryReader { geo in
                                let nonZero = root.children.filter { $0.size > 0 }
                                let total = Double(root.size > 0 ? root.size : 1)

                                HStack(spacing: 2) {
                                    ForEach(Array(nonZero.prefix(6).enumerated()), id: \.element.id) { index, child in
                                        let width = max(4, geo.size.width * CGFloat(Double(child.size) / total))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(colorForIndex(index))
                                            .frame(width: width, height: 8)
                                    }
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(16)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Child Nodes Grouped List
                        VStack(spacing: 0) {
                            ForEach(Array(root.children.enumerated()), id: \.element.id) { index, child in
                                spaceNodeRow(node: child, totalSize: root.size, color: colorForIndex(index))

                                if index < root.children.count - 1 {
                                    Divider()
                                        .padding(.leading, 44)
                                }
                            }
                        }
                        .background(Color(nsColor: .controlBackgroundColor))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            } else {
                ContentUnavailableView {
                    Label("Visualizza lo Spazio su Disco", systemImage: "circle.grid.cross")
                } description: {
                    Text("Avvia una scansione per visualizzare le cartelle più ingombranti della tua cartella utente.")
                } actions: {
                    Button("Avvia Scansione Spazio") {
                        SoundHaptics.tap()
                        state.scanSpaceLens()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private func spaceNodeRow(node: SpaceNode, totalSize: UInt64, color: Color) -> some View {
        let proportion = totalSize > 0 ? Double(node.size) / Double(totalSize) : 0

        return HStack(spacing: 12) {
            Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)
                .font(.system(size: 16))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(node.name)
                    .font(.body)
                    .foregroundStyle(.primary)

                // Sub-progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(nsColor: .separatorColor).opacity(0.3))
                            .frame(height: 3)

                        Capsule()
                            .fill(color)
                            .frame(width: max(3, geo.size.width * CGFloat(proportion)), height: 3)
                    }
                }
                .frame(height: 3)
            }

            Spacer()

            Text(node.formattedSize)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .monospacedDigit()

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
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.teal, .blue, .purple, .orange, .pink, .indigo, .mint]
        return palette[idx % palette.count]
    }
}
