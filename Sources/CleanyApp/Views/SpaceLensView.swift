import SwiftUI
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
                VStack(alignment: .leading, spacing: 3) {
                    Text("Space Lens")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Explore storage usage visually and identify oversized folders.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    state.scanSpaceLens()
                } label: {
                    Label(state.isScanningSpace ? "Scanning..." : "Scan Storage", systemImage: "circle.grid.cross.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(state.isScanningSpace)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.regularMaterial)

            Divider()

            if state.isScanningSpace {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Analyzing directory sizes...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else if let root = state.spaceRootNode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            Text(root.name)
                                .font(.headline)
                            Spacer()
                            Text(root.formattedSize)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        VStack(spacing: 10) {
                            ForEach(root.children) { child in
                                spaceNodeRow(node: child, totalSize: root.size)
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
                        .font(.system(size: 50))
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("Visualize Your Disk Space")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text("Quickly discover which folders are taking up the most room.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Start Space Scan") {
                        state.scanSpaceLens()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }
        }
    }

    private func spaceNodeRow(node: SpaceNode, totalSize: UInt64) -> some View {
        let proportion = totalSize > 0 ? Double(node.size) / Double(totalSize) : 0

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(node.isDirectory ? .blue : .secondary)

                Text(node.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                Text(node.formattedSize)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))

                Button("Finder") {
                    NSWorkspace.shared.selectFile(node.url.path, inFileViewerRootedAtPath: "")
                }
                .font(.caption2)
                .buttonStyle(.link)
            }

            // Visual Proportion Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 6)

                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(6, geo.size.width * CGFloat(proportion)), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
        )
    }
}
