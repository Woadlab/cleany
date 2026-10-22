import SwiftUI
import CleanyCore

public struct SidebarView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        VStack(spacing: 0) {
            // App Branding Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 26, height: 26)
                        .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 2)

                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("CLEANY")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.95))

                Spacer()

                Text("v1.0")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            Divider()
                .overlay(Color.white.opacity(0.08))

            // Navigation Sections List
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Smart Care Hero Item
                    VStack(alignment: .leading, spacing: 4) {
                        navRow(
                            item: .smartCare,
                            title: "Smart Care",
                            icon: "sparkles",
                            color: .blue,
                            badge: nil,
                            sizeText: state.totalFoundBytes > 0 ? state.formattedTotalBytes : nil
                        )
                    }

                    // Cleaning Section
                    VStack(alignment: .leading, spacing: 3) {
                        sectionHeader("CLEANING")

                        ForEach(JunkCategory.allCases) { category in
                            let size = state.categorySize(category)
                            let sizeFormatted = size > 0 ? state.categoryFormattedSize(category) : nil

                            navRow(
                                item: .category(category),
                                title: category.title,
                                icon: category.systemImage,
                                color: categoryColor(category),
                                badge: category.badge,
                                sizeText: sizeFormatted
                            )
                        }
                    }

                    // Utilities Section
                    VStack(alignment: .leading, spacing: 3) {
                        sectionHeader("UTILITIES")

                        navRow(
                            item: .maintenance,
                            title: "Maintenance",
                            icon: "wrench.and.screwdriver.fill",
                            color: .indigo,
                            badge: nil,
                            sizeText: "\(MaintenanceTask.allCases.count) tasks"
                        )

                        navRow(
                            item: .spaceLens,
                            title: "Space Lens",
                            icon: "circle.grid.cross.fill",
                            color: .teal,
                            badge: nil,
                            sizeText: "Storage"
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 14)
                .padding(.bottom, 16)
            }

            Spacer(minLength: 0)

            // Local Privacy Security Footer Pill
            Divider()
                .overlay(Color.white.opacity(0.08))

            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                    .shadow(color: Color.green.opacity(0.8), radius: 4, x: 0, y: 0)

                VStack(alignment: .leading, spacing: 1) {
                    Text("100% Local & Private")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    Text("Zero telemetry • No root daemon")
                        .font(.system(size: 9.5))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.green.opacity(0.8))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.03))
        }
        .frame(minWidth: 230, idealWidth: 245, maxWidth: 280)
        .background(Color(red: 0.06, green: 0.065, blue: 0.09).opacity(0.95))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 9.5, weight: .bold))
            .tracking(1.4)
            .foregroundStyle(.white.opacity(0.35))
            .padding(.horizontal, 10)
            .padding(.top, 4)
            .padding(.bottom, 2)
    }

    private func navRow(
        item: NavigationItem,
        title: String,
        icon: String,
        color: Color,
        badge: String?,
        sizeText: String?
    ) -> some View {
        let isSelected = state.selectedNav == item

        return Button {
            SoundHaptics.tap()
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                state.selectedNav = item
            }
        } label: {
            HStack(spacing: 10) {
                // Icon Bezel
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(isSelected ? color.opacity(0.25) : color.opacity(0.12))
                        .frame(width: 26, height: 26)

                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : color)
                }

                // Title - NEVER TRUNCATED
                Text(title)
                    .font(.system(size: 12.5, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.85))
                    .lineLimit(1)
                    .layoutPriority(1)

                Spacer(minLength: 4)

                // Optional Badge
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 8.5, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.pink.opacity(0.22))
                        .foregroundStyle(.pink)
                        .clipShape(Capsule())
                }

                // Optional Size pill
                if let size = sizeText {
                    Text(size)
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .white.opacity(0.45))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.18) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func categoryColor(_ category: JunkCategory) -> Color {
        switch category {
        case .aiClutter:
            return Color(red: 0.75, green: 0.35, blue: 0.95) // Electric Purple
        case .developerJunk:
            return Color(red: 0.25, green: 0.55, blue: 0.98) // Apple Blue
        case .systemJunk:
            return Color(red: 0.15, green: 0.75, blue: 0.75) // Vibrant Teal
        case .appLeftovers:
            return Color(red: 0.98, green: 0.55, blue: 0.15) // Deep Amber Orange
        case .trashBins:
            return Color(red: 0.95, green: 0.28, blue: 0.32) // Coral Red
        }
    }
}
