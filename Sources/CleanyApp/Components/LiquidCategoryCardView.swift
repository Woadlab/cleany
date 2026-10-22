import SwiftUI
import CleanyCore

/// Native macOS 27 Liquid Glass Category Platter.
/// Features optical glass refraction, dynamic fluid progress bar,
/// San Francisco typography, and spring interaction physics.
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
            SoundHaptics.tap()
            onSelect()
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                // Top Header Row
                HStack(alignment: .center, spacing: 10) {
                    // Glass Droplet Icon Container
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.18))
                            .frame(width: 38, height: 38)
                            .overlay(Circle().stroke(categoryColor.opacity(0.35), lineWidth: 1))

                        Image(systemName: category.systemImage)
                            .font(.system(size: 17, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(category.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 6)
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

                    Spacer()

                    // Trailing Hover Chevron
                    Image(systemName: "arrow.up.forward.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(isHovered ? categoryColor : Color.secondary.opacity(0.4))
                        .offset(x: isHovered ? 2 : 0, y: isHovered ? -2 : 0)
                }

                // Middle: Fluid Progress Bar
                VStack(alignment: .leading, spacing: 4) {
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
                                .frame(width: max(6, geo.size.width * CGFloat(min(1.0, max(0.05, percentage)))), height: 6)
                                .shadow(color: categoryColor.opacity(0.3), radius: 3, x: 0, y: 1)
                        }
                    }
                    .frame(height: 6)
                }

                // Bottom Metrics Row
                HStack(alignment: .lastTextBaseline) {
                    Text(size > 0 ? formattedSize : "0 B")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Spacer()

                    if size > 0 {
                        Text("\(count) element\(count == 1 ? "o" : "i")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(Capsule())
                    } else {
                        Text("Pulito")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(18)
            .liquidGlass(cornerRadius: 18, tint: categoryColor.opacity(isHovered ? 0.20 : 0.08), isInteractive: true)
            .scaleEffect(isHovered ? 1.015 : 1.0)
            .offset(y: isHovered ? -3 : 0)
            .animation(.spring(response: 0.28, dampingFraction: 0.78), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
