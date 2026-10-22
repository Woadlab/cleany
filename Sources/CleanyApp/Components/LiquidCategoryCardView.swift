import SwiftUI
import CleanyCore

/// Native macOS 27 Liquid Glass Category Platter.
/// Ultra-soft continuous curvature (22pt), fluid progress bar,
/// San Francisco typography without awkward word-wraps, and responsive hover physics.
public struct LiquidCategoryCardView: View {
    public let category: JunkCategory
    public let count: Int
    public let size: UInt64
    public let formattedSize: String
    public let percentage: Double
    public let isScanning: Bool
    public let onSelect: () -> Void

    @LocalVar private var isHovered: Bool = false

    public init(
        category: JunkCategory,
        count: Int,
        size: UInt64,
        formattedSize: String,
        percentage: Double = 0,
        isScanning: Bool = false,
        onSelect: @escaping () -> Void
    ) {
        self.category = category
        self.count = count
        self.size = size
        self.formattedSize = formattedSize
        self.percentage = percentage
        self.isScanning = isScanning
        self.onSelect = onSelect
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter: return .purple
        case .developerJunk: return .blue
        case .systemJunk: return .teal
        case .appLeftovers: return .orange
        case .trashBins: return .red
        }
    }

    public var body: some View {
        Button {
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                // Top Header Row
                HStack(alignment: .center, spacing: 12) {
                    // Soft Glass Droplet Icon Container
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.18))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(categoryColor.opacity(0.35), lineWidth: 1))

                        Image(systemName: category.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(category.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 2)
                                    .background(categoryColor.opacity(0.18))
                                    .foregroundStyle(categoryColor)
                                    .clipShape(Capsule())
                            }
                        }

                        Text(category.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 4)

                    // Soft Glass Hover Arrow Pill
                    Image(systemName: "arrow.up.forward")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isHovered ? .white : categoryColor)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(isHovered ? categoryColor : categoryColor.opacity(0.15))
                        )
                }

                // Middle: Fluid Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.06))
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor, categoryColor.opacity(0.75)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, geo.size.width * CGFloat(min(1.0, max(0.04, percentage)))), height: 6)
                            .shadow(color: categoryColor.opacity(0.35), radius: 3, x: 0, y: 1)
                    }
                }
                .frame(height: 6)

                // Bottom Metrics Row
                HStack(alignment: .lastTextBaseline) {
                    Text(size > 0 ? formattedSize : "0 B")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Spacer()

                    if size > 0 {
                        Text("\(count) element\(count == 1 ? "o" : "i")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.primary.opacity(0.06)))
                    } else {
                        Text("Pulito")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.primary.opacity(0.04)))
                    }
                }
            }
            .padding(18)
            .liquidGlass(cornerRadius: 22, tint: categoryColor.opacity(isHovered ? 0.18 : 0.07), isInteractive: true)
            .scaleEffect(isHovered ? 1.012 : 1.0)
            .offset(y: isHovered ? -2 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
