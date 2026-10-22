import SwiftUI
import AppKit
import CleanyCore

/// Single file/folder row displaying path, size, checkbox, and explanation.
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
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()

                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(item.isDirectory ? Color.blue : Color.secondary)
                    .font(.system(size: 15))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(item.formattedSize)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.explanation)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Text(item.path)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button {
                            NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: "")
                        } label: {
                            Label("Reveal in Finder", systemImage: "arrow.up.forward.app")
                                .font(.system(size: 11))
                        }
                        .buttonStyle(.link)
                    }
                }
                .padding(.leading, 28)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovered ? Color.primary.opacity(0.03) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
