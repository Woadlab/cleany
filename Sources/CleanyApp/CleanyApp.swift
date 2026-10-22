import SwiftUI
import CleanyCore

@main
struct CleanyApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(state: state)
            } detail: {
                switch state.selectedNav {
                case .smartCare:
                    DashboardView(state: state)
                case .category(let category):
                    CategoryDetailView(category: category, state: state)
                case .maintenance:
                    MaintenanceView(state: state)
                case .spaceLens:
                    SpaceLensView(state: state)
                }
            }
            .frame(minWidth: 920, minHeight: 620)
            .navigationTitle("Cleany")
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unifiedCompact)
    }
}
