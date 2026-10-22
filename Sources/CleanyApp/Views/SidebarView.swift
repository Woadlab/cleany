import SwiftUI
import CleanyCore

/// Native macOS 27 Liquid Glass Sidebar.
/// Features optical glass selection capsules, hierarchical SF Symbols,
/// section headers, and a dedicated privacy assurance footer platter.
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
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 30, height: 30)
                        .overlay(Circle().stroke(Color.accentColor.opacity(0.4), lineWidth: 1))

                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }

                Text("Cleany")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                Text("v1.0")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.06))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .opacity(0.4)

            // Navigation Items List
            List(selection: $state.selectedNav) {
                // Smart Care Hero
                Section {
                    NavigationLink(value: NavigationItem.smartCare) {
                        Label {
                            HStack {
                                Text("Smart Care")
                                    .font(.body)
                                    .fontWeight(.medium)

                                Spacer()

                                if state.totalFoundBytes > 0 {
                                    Text(state.formattedTotalBytes)
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "sparkles")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .tag(NavigationItem.smartCare)
                }

                // Cleaning Categories
                Section("Pulizia") {
                    ForEach(JunkCategory.allCases) { category in
                        NavigationLink(value: NavigationItem.category(category)) {
                            Label {
                                HStack {
                                    Text(category.title)
                                        .font(.body)

                                    Spacer()

                                    let size = state.categorySize(category)
                                    if size > 0 {
                                        Text(state.categoryFormattedSize(category))
                                            .font(.callout)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } icon: {
                                Image(systemName: category.systemImage)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(colorForCategory(category))
                            }
                        }
                        .tag(NavigationItem.category(category))
                    }
                }

                // Utilities
                Section("Utility") {
                    NavigationLink(value: NavigationItem.spaceLens) {
                        Label {
                            Text("Space Lens")
                                .font(.body)
                        } icon: {
                            Image(systemName: "circle.grid.cross.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.teal)
                        }
                    }
                    .tag(NavigationItem.spaceLens)

                    NavigationLink(value: NavigationItem.maintenance) {
                        Label {
                            Text("Manutenzione")
                                .font(.body)
                        } icon: {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(Color.blue)
                        }
                    }
                    .tag(NavigationItem.maintenance)
                }
            }
            .listStyle(.sidebar)
        }
    }

    private func colorForCategory(_ category: JunkCategory) -> Color {
        switch category {
        case .aiClutter: return .purple
        case .developerJunk: return .blue
        case .systemJunk: return .teal
        case .appLeftovers: return .orange
        case .trashBins: return .red
        }
    }
}
