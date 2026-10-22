import SwiftUI
import CleanyCore

/// Native Apple HIG macOS Sidebar using standard `List(selection:)` and `.listStyle(.sidebar)`.
/// Provides automatic system vibrancy, traffic-light synchronization, keyboard navigation,
/// and dynamic Light/Dark mode hierarchy.
public struct SidebarView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        List(selection: $state.selectedNav) {
            // Hero Smart Care Section
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

            // Cleaning Categories Section
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

            // Utilities Section
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
        .safeAreaInset(edge: .bottom) {
            // Subtle Native Privacy Footer
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.green)
                    .font(.callout)

                VStack(alignment: .leading, spacing: 1) {
                    Text("100% Locale e Privato")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text("Zero telemetria • Offline")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .overlay(Divider(), alignment: .top)
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
