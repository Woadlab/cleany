import SwiftUI
import CleanyCore

@main
struct CleanyApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(state: state)
                    .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 280)
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
            .frame(minWidth: 960, minHeight: 660)
            .navigationTitle("Cleany")
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Avvia Scansione Completa") {
                    state.startScanAll()
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            CommandMenu("Pulizia") {
                Button("Sposta nel Cestino") {
                    state.cleanSelected()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(state.totalFoundBytes == 0 || state.isCleaning)
            }
        }
    }
}
