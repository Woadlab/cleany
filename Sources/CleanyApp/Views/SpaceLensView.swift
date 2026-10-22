import SwiftUI
import AppKit
import CleanyCore

public struct StorageSegment: Identifiable {
    public let id: String
    public let title: String
    public let size: UInt64
    public let color: Color
    public let isFreeSpace: Bool

    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
}

/// Native macOS 27 Space Lens View.
/// Features a unified Apple System Settings-style storage bar (Occupied + Free space)
/// with interactive hover telemetry, comprehensive color legend, and Finder integration.
public struct SpaceLensView: View {
    @ObservedObject var state: AppState

    @LocalVar private var hoveredSegmentId: String? = nil

    public init(state: AppState) {
        self.state = state
    }

    private var diskCapacity: (free: UInt64, total: UInt64) {
        if let values = try? URL(fileURLWithPath: "/").resourceValues(forKeys: [.volumeAvailableCapacityKey, .volumeTotalCapacityKey]),
           let free = values.volumeAvailableCapacity,
           let total = values.volumeTotalCapacity {
            return (UInt64(max(0, free)), UInt64(max(0, total)))
        }
        return (0, 0)
    }

    private func buildSegments(root: SpaceNode) -> [StorageSegment] {
        var segments: [StorageSegment] = []
        let palette: [Color] = [.teal, .blue, .purple, .orange, .pink, .indigo, .mint]

        let nonZeroChildren = root.children.filter { $0.size > 0 }.sorted { $0.size > $1.size }
        let topCount = min(5, nonZeroChildren.count)

        for i in 0..<topCount {
            let child = nonZeroChildren[i]
            segments.append(StorageSegment(
                id: child.id.uuidString,
                title: child.name,
                size: child.size,
                color: palette[i % palette.count],
                isFreeSpace: false
            ))
        }

        let topSum = segments.reduce(0) { $0 + $1.size }
        if root.size > topSum {
            segments.append(StorageSegment(
                id: "other_user_files",
                title: "Altre cartelle",
                size: root.size - topSum,
                color: Color.secondary.opacity(0.4),
                isFreeSpace: false
            ))
        }

        let freeBytes = diskCapacity.free
        if freeBytes > 0 {
            segments.append(StorageSegment(
                id: "free_disk_space",
                title: "Spazio Libero",
                size: freeBytes,
                color: Color.primary.opacity(0.12),
                isFreeSpace: true
            ))
        }

        return segments
    }

    public var body: some View {
        ZStack {
            // macOS 27 Ambient Fluid Mesh Atmosphere
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Header Platter
                HStack(alignment: .center) {
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
                        state.scanSpaceLens()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.grid.cross.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(state.isScanningSpace ? "Scansione..." : "Scansiona Spazio")
                                .font(.system(size: 13.5, weight: .bold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.teal)
                    .clipShape(Capsule())
                    .disabled(state.isScanningSpace)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 22, tint: Color.teal.opacity(0.08), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                // Main Content
                if state.isScanningSpace {
                    VStack(spacing: 14) {
                        Spacer()
                        ProgressView()
                            .controlSize(.large)

                        Text("Analisi dello spazio su disco in corso...")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Calcolo ricorsivo delle dimensioni delle cartelle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let root = state.spaceRootNode {
                    let segments = buildSegments(root: root)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Unified Apple-Style Storage Bar Platter
                            VStack(alignment: .leading, spacing: 14) {
                                // Dynamic Header with Hover Telemetry
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

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(root.name)
                                            .font(.headline)
                                            .foregroundStyle(.primary)

                                        if let hoveredId = hoveredSegmentId,
                                           let hovered = segments.first(where: { $0.id == hoveredId }) {
                                            Text("\(hovered.title): \(hovered.formattedSize)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(hovered.color == Color.primary.opacity(0.12) ? Color.secondary : hovered.color)
                                        } else {
                                            Text("Spazio totale analizzato: \(root.formattedSize)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text(root.formattedSize)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }

                                // Single Unified System Storage Bar (Zero Overflow Guarantee)
                                GeometryReader { geo in
                                    let totalBytes = max(1, segments.reduce(0) { $0 + $1.size })
                                    let availableWidth = geo.size.width
                                    let spacing: CGFloat = 2.0
                                    let totalSpacing = CGFloat(max(0, segments.count - 1)) * spacing
                                    let netWidth = max(0, availableWidth - totalSpacing)

                                    HStack(spacing: spacing) {
                                        ForEach(segments) { segment in
                                            let fraction = Double(segment.size) / Double(totalBytes)
                                            let segWidth = max(4, CGFloat(fraction) * netWidth)
                                            let isHovered = hoveredSegmentId == segment.id

                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(segment.color)
                                                .frame(width: segWidth, height: 16)
                                                .brightness(isHovered ? 0.15 : 0.0)
                                                .scaleEffect(isHovered ? 1.04 : 1.0)
                                                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
                                                .onHover { hovering in
                                                    hoveredSegmentId = hovering ? segment.id : nil
                                                }
                                        }
                                    }
                                }
                                .frame(height: 16)
                                .clipShape(Capsule())

                                // Color Legend Underneath Bar
                                FlowLegendView(segments: segments, hoveredId: $hoveredSegmentId)
                            }
                            .padding(20)
                            .liquidGlass(cornerRadius: 22, tint: Color.teal.opacity(0.06), isInteractive: false)
                            .padding(.horizontal, 24)
                            .padding(.top, 14)

                            // Directory Tiles List
                            VStack(spacing: 8) {
                                ForEach(Array(root.children.enumerated()), id: \.element.id) { index, child in
                                    spaceFolderTile(node: child, totalSize: root.size, color: colorForIndex(index))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 28)
                        }
                    }
                } else {
                    VStack {
                        Spacer()
                        ContentUnavailableView {
                            Label("Visualizza lo Spazio su Disco", systemImage: "circle.grid.cross")
                        } description: {
                            Text("Avvia una scansione per visualizzare la suddivisione dello spazio tra le cartelle principali.")
                        } actions: {
                            Button("Avvia Scansione Spazio") {
                                state.scanSpaceLens()
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.teal)
                            .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private func spaceFolderTile(node: SpaceNode, totalSize: UInt64, color: Color) -> some View {
        let proportion = totalSize > 0 ? min(1.0, Double(node.size) / Double(totalSize)) : 0

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 32, height: 32)

                Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(node.name)
                    .font(.system(size: 13.5, weight: .semibold))
                    .foregroundStyle(.primary)

                // Sub-proportion bar strictly bounded
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
                .background(Capsule().fill(Color.primary.opacity(0.05)))

            Button {
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
        .liquidGlass(cornerRadius: 16, tint: color.opacity(0.03), isInteractive: true)
    }

    private func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.teal, .blue, .purple, .orange, .pink, .indigo, .mint]
        return palette[idx % palette.count]
    }
}

/// Responsive flow legend for storage bar segments
struct FlowLegendView: View {
    let segments: [StorageSegment]
    @Binding var hoveredId: String?

    var body: some View {
        HStack(spacing: 16) {
            ForEach(segments) { segment in
                HStack(spacing: 6) {
                    Circle()
                        .fill(segment.color)
                        .frame(width: 8, height: 8)

                    Text(segment.title)
                        .font(.caption)
                        .foregroundStyle(hoveredId == segment.id ? .primary : .secondary)
                        .fontWeight(hoveredId == segment.id ? .bold : .regular)

                    Text(segment.formattedSize)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
                .contentShape(Rectangle())
                .onHover { hovering in
                    hoveredId = hovering ? segment.id : nil
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
