import SwiftUI
import CleanyCore

/// Interactive card presenting a single junk category with proportional share bar,
/// refined typography, and responsive hover feedback.
public struct MetricCardView: View {
    public let category: JunkCategory
    public let count: Int
    public let formattedSize: String
    public let percentage: Double
    public let isSelected: Bool
    public let onSelect: () -> Void

    @LocalVar private var isHovered: Bool = false

    public init(
        category: JunkCategory,
        count: Int,
        formattedSize: String,
        percentage: Double = 0,
        isSelected: Bool = false,
        onSelect: @escaping () -> Void
    ) {
        self.category = category
        self.count = count
        self.formattedSize = formattedSize
        self.percentage = percentage
        self.isSelected = isSelected
        self.onSelect = onSelect
    }

    public var body: some View {
        Button {
            SoundHaptics.tap()
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.12))
                            .frame(width: 38, height: 38)

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
                    } else if percentage > 0.01 {
                        Text("\(Int(percentage * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(categoryColor.opacity(0.9))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(count > 0 ? "\(count) item\(count == 1 ? "" : "s") found" : "Clean")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }

                // Proportional horizontal mini bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.04))
                            .frame(height: 4)

                        Capsule()
                            .fill(categoryColor)
                            .frame(width: max(4, geo.size.width * CGFloat(min(1.0, max(0.0, percentage)))), height: 4)
                    }
                }
                .frame(height: 4)

                HStack(alignment: .lastTextBaseline) {
                    Text(count > 0 ? formattedSize : "0 B")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(count > 0 ? .primary : .secondary)

                    Spacer()

                    HStack(spacing: 3) {
                        Text("View")
                            .font(.system(size: 11, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .bold))
                            .offset(x: isHovered ? 2 : 0)
                    }
                    .foregroundStyle(isHovered ? categoryColor : .secondary)
                    .opacity(count > 0 ? 1 : 0.4)
                }
            }
            .padding(16)
            .frame(minHeight: 140)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.85 : 0.45))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? categoryColor :
                        (isHovered ? categoryColor.opacity(0.35) : Color.primary.opacity(0.06)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isHovered ? 1.012 : 1.0)
            .shadow(color: Color.black.opacity(isHovered ? 0.06 : 0.0), radius: 8, x: 0, y: 4)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isHovered)
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
