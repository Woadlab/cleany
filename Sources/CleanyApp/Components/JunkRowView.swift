import SwiftUI
import AppKit
import CleanyCore

/// Native Apple HIG List Row for individual junk files and folders.
/// Uses semantic typography, hierarchical SF Symbols, and standard AppKit Finder integration.
public struct JunkRowView: View {
    public let item: JunkItem
    public let onToggle: () -> Void

    @LocalVar private var isExpanded: Bool = false

    public init(item: JunkItem, onToggle: @escaping () -> Void) {
        self.item = item
        self.onToggle = onToggle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                // Checkbox
                Toggle("", isOn: Binding(
                    get: { item.isSelected },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(.checkbox)
                .labelsHidden()

                // File or Folder Icon
                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(item.isDirectory ? Color.accentColor : Color.secondary)
                    .font(.system(size: 16))
                    .frame(width: 20)

                // Item Name and Category Subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.displayName)
                        .font(.body)
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
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .monospacedDigit()

                // Reveal in Finder Button
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

                // Info / Disclosure Toggle
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

            // Expanded Path Information
            if isExpanded {
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.path)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .textSelection(.enabled)

                    Text(item.explanation)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.leading, 32)
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 3)
    }
}
