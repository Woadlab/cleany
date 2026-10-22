import SwiftUI
import AppKit
import CleanyCore

public struct SpaceLensView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            AtmosphericBackgroundView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Space Lens")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Explore storage usage visually and identify oversized folders.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    Button {
                        SoundHaptics.tap()
                        state.scanSpaceLens()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "circle.grid.cross.fill")
                                .font(.system(size: 11))
                            Text(state.isScanningSpace ? "Scanning..." : "Scan Storage")
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.teal, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(state.isScanningSpace)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.25))

                Divider().overlay(Color.white.opacity(0.08))

                if state.isScanningSpace {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Analyzing directory hierarchy...")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text("Calculating folder sizes recursively")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.45))
                        Spacer()
                    }
                } else if let root = state.spaceRootNode {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            // Doppelrand Overview Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.teal.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "internaldrive.fill")
                                            .foregroundStyle(Color.teal)
                                            .font(.system(size: 14))
                                    }

                                    Text(root.name)
                                        .font(.system(size: 14.5, weight: .bold))
                                        .foregroundStyle(.white)

                                    Spacer()

                                    Text(root.formattedSize)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.cyan)
                                }

                                // DaisyDisk-Style Multi-Segmented Storage Bar
                                GeometryReader { geo in
                                    let nonZeroChildren = root.children.filter { $0.size > 0 }
                                    let total = Double(root.size > 0 ? root.size : 1)

                                    HStack(spacing: 2.5) {
                                        ForEach(Array(nonZeroChildren.prefix(7).enumerated()), id: \.element.id) { index, child in
                                            let width = max(6, geo.size.width * CGFloat(Double(child.size) / total))
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(colorForIndex(index))
                                                .frame(width: width, height: 12)
                                                .shadow(color: colorForIndex(index).opacity(0.4), radius: 3)
                                        }
                                    }
                                }
                                .frame(height: 12)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(red: 0.08, green: 0.085, blue: 0.12).opacity(0.85))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
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
                                LinearGradient(colors: [.teal, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .shadow(color: Color.teal.opacity(0.5), radius: 10)

                        Text("Visualize Your Disk Space")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Discover which folders are consuming the most room in your user library and home directories.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: 380)
                            .multilineTextAlignment(.center)

                        Button {
                            SoundHaptics.tap()
                            state.scanSpaceLens()
                        } label: {
                            Text("Start Storage Scan")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 9)
                                .background(Capsule().fill(LinearGradient(colors: [.teal, .blue], startPoint: .leading, endPoint: .trailing)))
                                .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                                .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 3)
                        }
                        .buttonStyle(PressableButtonStyle())
                        Spacer()
                    }
                }
            }
        }
    }

    private func spaceNodeRow(node: SpaceNode, totalSize: UInt64, color: Color) -> some View {
        let proportion = totalSize > 0 ? Double(node.size) / Double(totalSize) : 0

        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color.opacity(0.18))
                        .frame(width: 26, height: 26)

                    Image(systemName: node.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundStyle(color)
                        .font(.system(size: 12))
                }

                Text(node.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))

                Spacer()

                Text(node.formattedSize)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Button {
                    SoundHaptics.tap()
                    NSWorkspace.shared.selectFile(node.url.path, inFileViewerRootedAtPath: "")
                } label: {
                    HStack(spacing: 3) {
                        Text("Finder")
                            .font(.system(size: 10, weight: .semibold))
                        Image(systemName: "arrow.up.forward.app")
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(Color.cyan)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.cyan.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Visual Proportion Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 5)

                    Capsule()
                        .fill(color)
                        .frame(width: max(5, geo.size.width * CGFloat(proportion)), height: 5)
                        .shadow(color: color.opacity(0.5), radius: 3)
                }
            }
            .frame(height: 5)
        }
        .padding(11)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(red: 0.08, green: 0.085, blue: 0.12).opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func colorForIndex(_ idx: Int) -> Color {
        let palette: [Color] = [
            Color(red: 0.25, green: 0.55, blue: 0.98),
            Color(red: 0.75, green: 0.35, blue: 0.95),
            Color(red: 0.15, green: 0.75, blue: 0.75),
            Color(red: 0.98, green: 0.55, blue: 0.15),
            Color(red: 0.95, green: 0.28, blue: 0.32),
            Color(red: 0.30, green: 0.85, blue: 0.55),
            Color(red: 0.55, green: 0.40, blue: 0.95)
        ]
        return palette[idx % palette.count]
    }
}
