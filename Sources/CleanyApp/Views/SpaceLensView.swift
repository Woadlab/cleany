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
                VStack(spacing: 14) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.1)
                    Text("Analyzing directory sizes...")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else if let root = state.spaceRootNode {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(root.name)
                                .font(.system(size: 13, weight: .semibold))
                            Spacer()
                            Text(root.formattedSize)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                        VStack(spacing: 8) {
                            ForEach(root.children) { child in
                                spaceNodeRow(node: child, totalSize: root.size)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            } else {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "circle.grid.cross")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("Visualize Your Disk Space")
                        .font(.system(size: 16, weight: .semibold))

                    Text("Quickly discover which folders are taking up the most room in your Home folder.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 340)
                        .multilineTextAlignment(.center)

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
            HStack(spacing: 10) {
                Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(node.isDirectory ? Color.blue : Color.secondary)
                    .font(.system(size: 14))

                Text(node.name)
                    .font(.system(size: 13, weight: .medium))

                Spacer()

                Text(node.formattedSize)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))

                Button {
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
                        .fill(Color.primary.opacity(0.05))
                        .frame(height: 5)

                    Capsule()
                        .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(5, geo.size.width * CGFloat(proportion)), height: 5)
                }
            }
            .frame(height: 5)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
        )
    }
}
