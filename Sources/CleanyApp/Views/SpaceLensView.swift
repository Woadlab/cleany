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
/// Features clean, unambiguous separation between target folder analysis and physical volume capacity.
/// Fully responsive non-hyphenating legend grid, specular hover telemetry, and Finder deep-links.
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

    /// Builds segments that strictly represent the analyzed target folder (100% coherence)
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
                color: Color.secondary.opacity(0.5),
                isFreeSpace: false
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
                    .cleanyGlassProminent(tint: .teal)
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
                        VStack(alignment: .leading, spacing: 18) {
                            // Section 1: Analyzed Target Folder Breakdown Platter
                            VStack(alignment: .leading, spacing: 14) {
                                // Dynamic Header with Hover Telemetry
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.teal.opacity(0.18))
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "folder.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .foregroundStyle(Color.teal)
                                            .font(.system(size: 16))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Cartella: \(root.name)")
                                            .font(.headline)
                                            .foregroundStyle(.primary)

                                        if let hoveredId = hoveredSegmentId,
                                           let hovered = segments.first(where: { $0.id == hoveredId }) {
                                            let percent = root.size > 0 ? (Double(hovered.size) / Double(root.size) * 100.0) : 0
                                            Text("\(hovered.title): \(hovered.formattedSize) (\(String(format: "%.1f%%", percent)) dello spazio analizzato)")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(hovered.color)
                                        } else {
                                            Text("Ripartizione dello spazio analizzato: \(root.formattedSize)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text(root.formattedSize)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                }

                                // Interactive Unified Storage Bar (100% Coherent to Folder Size)
                                GeometryReader { geo in
                                    let totalBytes = max(1, root.size)
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
                                                .brightness(isHovered ? 0.18 : 0.0)
                                                .scaleEffect(isHovered ? 1.03 : 1.0)
                                                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isHovered)
                                                .onHover { hovering in
                                                    hoveredSegmentId = hovering ? segment.id : nil
                                                }
                                        }
                                    }
                                }
                                .frame(height: 16)
                                .clipShape(Capsule())

                                // Responsive Color Legend Grid (Zero Hyphenation)
                                FlowLegendView(segments: segments, totalSize: root.size, hoveredId: $hoveredSegmentId)
                            }
                            .padding(20)
                            .liquidGlass(cornerRadius: 22, tint: Color.teal.opacity(0.06), isInteractive: false)
                            .padding(.horizontal, 24)
                            .padding(.top, 14)

                            // Section 2: Overall Hardware Volume Overview (Macintosh HD)
                            if diskCapacity.total > 0 {
                                let total = diskCapacity.total
                                let free = diskCapacity.free
                                let used = max(0, total - free)
                                let usedFraction = Double(used) / Double(total)
                                let freeStr = ByteCountFormatter.string(fromByteCount: Int64(free), countStyle: .file)
                                let usedStr = ByteCountFormatter.string(fromByteCount: Int64(used), countStyle: .file)
                                let totalStr = ByteCountFormatter.string(fromByteCount: Int64(total), countStyle: .file)

                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.18))
                                                .frame(width: 32, height: 32)

                                            Image(systemName: "internaldrive.fill")
                                                .symbolRenderingMode(.hierarchical)
                                                .foregroundStyle(Color.blue)
                                                .font(.system(size: 15))
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Disco di Avvio (Macintosh HD)")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.primary)

                                            Text("\(freeStr) disponibili su \(totalStr)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Text(totalStr)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }

                                    // Slim Apple-Style System Storage Bar
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Color.primary.opacity(0.08))
                                                .frame(height: 8)

                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.blue, Color.teal],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: max(6, geo.size.width * CGFloat(usedFraction)), height: 8)
                                        }
                                    }
                                    .frame(height: 8)

                                    HStack(spacing: 20) {
                                        HStack(spacing: 6) {
                                            Circle().fill(Color.blue).frame(width: 7, height: 7)
                                            Text("Occupato: \(usedStr)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }

                                        HStack(spacing: 6) {
                                            Circle().fill(Color.primary.opacity(0.18)).frame(width: 7, height: 7)
                                            Text("Disponibile: \(freeStr)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(16)
                                .liquidGlass(cornerRadius: 18, tint: Color.blue.opacity(0.04), isInteractive: false)
                                .padding(.horizontal, 24)
                            }

                            // Section 3: Directory Tiles List
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
                            .cleanyGlassProminent(tint: .teal)
                            .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .font(.system(size: 15))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(node.name)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(node.url.path)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(node.formattedSize)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text(String(format: "%.1f%%", proportion * 100.0))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Button {
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: node.url.path)
            } label: {
                Image(systemName: "arrow.up.forward.square")
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

/// Responsive flow legend for storage bar segments with zero syllable hyphenation
struct FlowLegendView: View {
    let segments: [StorageSegment]
    let totalSize: UInt64
    @Binding var hoveredId: String?

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 155, maximum: 240), spacing: 10)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(segments) { segment in
                let isHovered = hoveredId == segment.id
                let percentage = totalSize > 0 ? (Double(segment.size) / Double(totalSize) * 100.0) : 0

                HStack(spacing: 6) {
                    Circle()
                        .fill(segment.color)
                        .frame(width: 8, height: 8)

                    Text(segment.title)
                        .font(.caption)
                        .foregroundStyle(isHovered ? .primary : .secondary)
                        .fontWeight(isHovered ? .bold : .medium)
                        .lineLimit(1)

                    Text("\(segment.formattedSize) (\(String(format: "%.1f%%", percentage)))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isHovered ? segment.color.opacity(0.14) : Color.clear)
                )
                .contentShape(Rectangle())
                .onHover { hovering in
                    hoveredId = hovering ? segment.id : nil
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
