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
                            .font(.body)
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
                            } icon: {
                                Image(systemName: category.systemImage)
                                    .foregroundStyle(categoryColor(category))
                            }

                            Spacer()

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.pink.opacity(0.18))
                                    .foregroundStyle(.pink)
                                    .clipShape(Capsule())
                            }

                            let size = state.categorySize(category)
                            if size > 0 {
                                Text(state.categoryFormattedSize(category))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Tools") {
                NavigationLink(value: NavigationItem.maintenance) {
                    Label("Maintenance", systemImage: "wrench.and.screwdriver.fill")
                        .foregroundStyle(.primary)
                }

                NavigationLink(value: NavigationItem.spaceLens) {
                    Label("Space Lens", systemImage: "circle.grid.cross.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Divider()
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    Text("100% Local • Zero Telemetry")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(.regularMaterial)
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
