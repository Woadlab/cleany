import SwiftUI
import AppKit
import CleanyCore

/// Native macOS 27 Liquid Glass List Row for junk files and directories.
/// Encapsulated in an optical glass tile with checkbox, path inspection, and Finder actions.
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
                // Checkbox Toggle
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()

                // File/Folder Glyphed Droplet
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(item.isDirectory ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.06))
                        .frame(width: 30, height: 30)

                    Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(item.isDirectory ? Color.accentColor : Color.secondary)
                        .font(.system(size: 14))
                }

                // File Name & Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Formatted Size
                Text(item.formattedSize)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Capsule())

                // Finder Reveal Action
                Button {
                    SoundHaptics.tap()
                    NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: "")
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Mostra nel Finder")

                // Disclosure Button
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "info.circle")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.borderless)
                .help("Dettagli percorso")
            }

            // Expanded Explanation & Path Drawer
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.path)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .textSelection(.enabled)

                    Text(item.explanation)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.leading, 42)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 12, tint: Color.primary.opacity(isHovered ? 0.08 : 0.02), isInteractive: true)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
