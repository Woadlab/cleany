import SwiftUI
import CleanyCore

/// Double-Bezel (Doppelrand) hardware-inspired interactive category card.
/// Features nested concentric glass containers, glowing neon micro-bars,
/// and haptic spring physics.
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
            // Outer Bezel Shell (Doppelrand architecture)
            VStack(alignment: .leading, spacing: 10) {
                // Header: Icon + Badge / Share %
                HStack(alignment: .center) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [categoryColor.opacity(0.28), categoryColor.opacity(0.08)],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 36, height: 36)
                            .overlay(Circle().stroke(categoryColor.opacity(0.35), lineWidth: 1))
                            .shadow(color: categoryColor.opacity(isHovered ? 0.45 : 0.15), radius: 6, x: 0, y: 2)

                        Image(systemName: category.systemImage)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(categoryColor)
                    }

                    Spacer()

                    if let badge = category.badge {
                        Text(badge)
                            .font(.system(size: 8.5, weight: .bold))
                            .tracking(0.5)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2.5)
                            .background(Color.pink.opacity(0.20))
                            .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.6))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.pink.opacity(0.35), lineWidth: 0.8))
                    } else if percentage > 0.01 {
                        Text("\(Int(percentage * 100))%")
                            .font(.system(size: 9.5, weight: .bold, design: .rounded))
                            .foregroundStyle(categoryColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(categoryColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }

                // Title & Subtitle
                VStack(alignment: .leading, spacing: 1) {
                    Text(category.title)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(1)

                    Text(count > 0 ? "\(count) items detected" : "Clean")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                }

                // Proportional Luminous Mini-Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 3.5)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [categoryColor.opacity(0.7), categoryColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(4, geo.size.width * CGFloat(min(1.0, max(0.0, percentage)))), height: 3.5)
                            .shadow(color: categoryColor.opacity(percentage > 0 ? 0.6 : 0), radius: 3)
                    }
                }
                .frame(height: 3.5)
                .padding(.top, 2)

                // Metric + Action Row
                HStack(alignment: .lastTextBaseline) {
                    Text(count > 0 ? formattedSize : "0 B")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(count > 0 ? Color.white : Color.white.opacity(0.3))

                    Spacer()

                    HStack(spacing: 3) {
                        Text("Inspect")
                            .font(.system(size: 10.5, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8.5, weight: .bold))
                    }
                    .foregroundStyle(isHovered ? categoryColor : Color.white.opacity(0.4))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(isHovered ? categoryColor.opacity(0.15) : Color.white.opacity(0.04))
                    )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(red: 0.08, green: 0.085, blue: 0.12).opacity(isHovered ? 0.95 : 0.75))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        isSelected ? categoryColor :
                        (isHovered ? categoryColor.opacity(0.4) : Color.white.opacity(0.08)),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .overlay(
                // Specular top highlight
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .padding(0.5)
            )
            .offset(y: isHovered ? -3 : 0)
            .scaleEffect(isHovered ? 1.015 : 1.0)
            .shadow(
                color: isHovered ? categoryColor.opacity(0.25) : Color.black.opacity(0.3),
                radius: isHovered ? 12 : 6,
                x: 0,
                y: isHovered ? 6 : 2
            )
            .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter:
            return Color(red: 0.75, green: 0.35, blue: 0.95)
        case .developerJunk:
            return Color(red: 0.25, green: 0.55, blue: 0.98)
        case .systemJunk:
            return Color(red: 0.15, green: 0.75, blue: 0.75)
        case .appLeftovers:
            return Color(red: 0.98, green: 0.55, blue: 0.15)
        case .trashBins:
            return Color(red: 0.95, green: 0.28, blue: 0.32)
        }
    }
}
