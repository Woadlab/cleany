import SwiftUI
import AppKit
import CleanyCore

/// Modern, obsidian-glass file/folder row displaying path, size, checkbox, and explanation.
public struct JunkRowView: View {
    public let item: JunkItem
    public let onToggle: () -> Void

    @LocalVar private var isExpanded: Bool = false
    @LocalVar private var isHovered: Bool = false

    public init(item: JunkItem, onToggle: @escaping () -> Void) {
        self.item = item
        self.onToggle = onToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                // Checkbox
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()

                // File/Folder Glyph
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(item.isDirectory ? Color.blue.opacity(0.18) : Color.white.opacity(0.08))
                        .frame(width: 28, height: 28)

                    Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                        .foregroundStyle(item.isDirectory ? Color.cyan : Color.white.opacity(0.7))
                        .font(.system(size: 13))
                }

                // Name & Subtitle
                VStack(alignment: .leading, spacing: 1.5) {
                    Text(item.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }

                Spacer()

                // Size Badge
                Text(item.formattedSize)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3.5)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 0.8))
                    )

                // Expand Chevron
                Button {
                    SoundHaptics.tap()
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(Color.white.opacity(isHovered ? 0.08 : 0.02)))
                }
                .buttonStyle(.plain)
            }

            // Expanded File Inspection Drawer
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.explanation)
                        .font(.system(size: 11.5))
                        .foregroundStyle(.white.opacity(0.65))

                    HStack(spacing: 8) {
                        Text(item.path)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.45))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button {
                            SoundHaptics.tap()
                            NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: "")
                        } label: {
                            HStack(spacing: 4) {
                                Text("Reveal in Finder")
                                    .font(.system(size: 11, weight: .semibold))
                                Image(systemName: "arrow.up.forward.app")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(Color.cyan)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.cyan.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 40)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isHovered ? Color.white.opacity(0.07) : Color.white.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isHovered ? Color.white.opacity(0.14) : Color.white.opacity(0.04), lineWidth: 1)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
