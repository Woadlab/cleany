import SwiftUI
import CleanyCore

/// Interactive card presenting a single junk category with size, count, and quick selection.
public struct MetricCardView: View {
    public let category: JunkCategory
    public let count: Int
    public let formattedSize: String
    public let isSelected: Bool
    public let onSelect: () -> Void

    public init(
        category: JunkCategory,
        count: Int,
        formattedSize: String,
        isSelected: Bool = false,
        onSelect: @escaping () -> Void
    ) {
        self.category = category
        self.count = count
        self.formattedSize = formattedSize
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: category.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(categoryColor)
                    }

                    Spacer()

                    if let badge = category.badge {
                        Text(badge)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.pink.opacity(0.18))
                            .foregroundStyle(.pink)
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(count > 0 ? "\(count) items" : "No items")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                Text(count > 0 ? formattedSize : "0 B")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(count > 0 ? .primary : .secondary)
            }
            .padding(16)
            .frame(minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? categoryColor : Color.primary.opacity(0.06), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter:
            return .purple
        case .developerJunk:
            return .blue
        case .systemJunk:
            return .teal
        case .appLeftovers:
            return .orange
        case .trashBins:
            return .red
        }
    }
}
