import SwiftUI
import AppKit
import CleanyCore

public struct SpaceLensView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space Lens")
                        .font(.system(size: 18, weight: .bold))

                    Text("Explore storage usage visually and identify oversized folders.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    SoundHaptics.tap()
                    state.scanSpaceLens()
                } label: {
                    Label(state.isScanningSpace ? "Scanning..." : "Scan Storage", systemImage: "circle.grid.cross")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.isScanningSpace)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            if state.isScanningSpace {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Analyzing directory hierarchy...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("Calculating folder sizes recursively")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.7))
                    Spacer()
                }
            } else if let root = state.spaceRootNode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Overview Card with Segmented Bar
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "internaldrive.fill")
                                    .foregroundStyle(.blue)
                                Text(root.name)
                                    .font(.system(size: 14, weight: .bold))
                                Spacer()
                                Text(root.formattedSize)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }

                            // Proportional Multi-Segmented Storage Bar
                            GeometryReader { geo in
                                let nonZeroChildren = root.children.filter { $0.size > 0 }
                                let total = Double(root.size > 0 ? root.size : 1)

                                HStack(spacing: 2) {
                                    ForEach(Array(nonZeroChildren.prefix(6).enumerated()), id: \.element.id) { index, child in
                                        let width = max(4, geo.size.width * CGFloat(Double(child.size) / total))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(colorForIndex(index))
                                            .frame(width: width, height: 10)
                                    }
                                }
                            }
                            .frame(height: 10)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        // Child Nodes List
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
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "circle.grid.cross")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text("Visualize Your Disk Space")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Quickly discover which folders are taking up the most room in your Home folder.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 360)
                        .multilineTextAlignment(.center)

                    Button("Start Space Scan") {
                        SoundHaptics.tap()
                        state.scanSpaceLens()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    Spacer()
                }
            }
        }
    }

    private func spaceNodeRow(node: SpaceNode, totalSize: UInt64, color: Color) -> some View {
        let proportion = totalSize > 0 ? Double(node.size) / Double(totalSize) : 0

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(color)
                    .font(.system(size: 14))

                Text(node.name)
                    .font(.system(size: 13, weight: .medium))

                Spacer()

                Text(node.formattedSize)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))

                Button {
                    SoundHaptics.tap()
                    NSWorkspace.shared.selectFile(node.url.path, inFileViewerRootedAtPath: "")
                } label: {
                    Label("Finder", systemImage: "arrow.up.forward.app")
                        .font(.system(size: 10))
                }
                .buttonStyle(.link)
            }

            // Visual Proportion Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.04))
                        .frame(height: 5)

                    Capsule()
                        .fill(color)
                        .frame(width: max(5, geo.size.width * CGFloat(proportion)), height: 5)
                }
            }
            .frame(height: 5)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.35))
        )
    }

    private func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [.blue, .purple, .teal, .orange, .pink, .indigo, .cyan, .mint]
        return palette[idx % palette.count]
    }
}
