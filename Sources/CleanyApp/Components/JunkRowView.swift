import SwiftUI
import CleanyCore

/// Single file/folder row displaying path, size, checkbox, and explanation.
public struct JunkRowView: View {
    public let item: JunkItem
    public let onToggle: () -> Void

    @LocalVar private var isExpanded: Bool = false

    public init(item: JunkItem, onToggle: @escaping () -> Void) {
        self.item = item
        self.onToggle = onToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()

                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(item.isDirectory ? .blue : .secondary)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(item.formattedSize)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .buttonStyle(.plain)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(item.path)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Spacer()

                        Button("Reveal in Finder") {
                            NSWorkspace.shared.selectFile(item.path, inFileViewerRootedAtPath: "")
                        }
                        .font(.caption2)
                        .buttonStyle(.link)
                    }
                }
                .padding(.leading, 32)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(item.isSelected ? Color.primary.opacity(0.02) : Color.clear)
        )
    }
}
