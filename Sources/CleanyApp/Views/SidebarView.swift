import SwiftUI
import CleanyCore

public struct SidebarView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        List(selection: $state.selectedNav) {
            Section {
                NavigationLink(value: NavigationItem.smartCare) {
                    Label {
                        Text("Smart Care")
                            .font(.system(size: 13, weight: .medium))
                    } icon: {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.blue)
                    }
                }
            }

            Section("Cleaning") {
                ForEach(JunkCategory.allCases) { category in
                    NavigationLink(value: NavigationItem.category(category)) {
                        HStack {
                            Label {
                                Text(category.title)
                                    .font(.system(size: 13))
                            } icon: {
                                Image(systemName: category.systemImage)
                                    .foregroundStyle(categoryColor(category))
                            }

                            Spacer()

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1.5)
                                    .background(Color.pink.opacity(0.15))
                                    .foregroundStyle(.pink)
                                    .clipShape(Capsule())
                            }

                            let size = state.categorySize(category)
                            if size > 0 {
                                Text(state.categoryFormattedSize(category))
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Utilities") {
                NavigationLink(value: NavigationItem.maintenance) {
                    Label {
                        Text("Maintenance")
                            .font(.system(size: 13))
                    } icon: {
                        Image(systemName: "wrench.and.screwdriver")
                            .foregroundStyle(.secondary)
                    }
                }

                NavigationLink(value: NavigationItem.spaceLens) {
                    Label {
                        Text("Space Lens")
                            .font(.system(size: 13))
                    } icon: {
                        Image(systemName: "circle.grid.cross")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)

                    Text("100% Local • Zero Telemetry")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private func categoryColor(_ category: JunkCategory) -> Color {
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
