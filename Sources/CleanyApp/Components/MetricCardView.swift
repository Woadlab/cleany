import SwiftUI
import CleanyCore

/// Interactive card presenting a single junk category with size, count, and quick selection.
public struct MetricCardView: View {
    public let category: JunkCategory
    public let count: Int
    public let formattedSize: String
    public let isSelected: Bool
    public let onSelect: () -> Void

    @LocalVar private var isHovered: Bool = false

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
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.12))
                            .frame(width: 36, height: 36)

                        Image(systemName: category.systemImage)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(categoryColor)
                    }

                    Spacer()

                    if let badge = category.badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(Color.pink.opacity(0.15))
                            .foregroundStyle(.pink)
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(category.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(count > 0 ? "\(count) item\(count == 1 ? "" : "s") found" : "No items detected")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 6)

                HStack(alignment: .lastTextBaseline) {
                    Text(count > 0 ? formattedSize : "0 B")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(count > 0 ? .primary : .secondary)

                    Spacer()

                    HStack(spacing: 2) {
                        Text("Review")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                    }
                    .foregroundStyle(isHovered ? categoryColor : .secondary)
                    .opacity(count > 0 ? 1 : 0.4)
                }
            }
            .padding(16)
            .frame(minHeight: 135)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.9 : 0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? categoryColor :
                        (isHovered ? categoryColor.opacity(0.3) : Color.primary.opacity(0.06)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.black.opacity(isHovered ? 0.05 : 0.0), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
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
