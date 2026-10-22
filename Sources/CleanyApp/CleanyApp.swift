import SwiftUI
import CleanyCore

@main
struct CleanyApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(state: state)
                    .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 270)
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
            .frame(minWidth: 880, minHeight: 580)
            .navigationTitle("Cleany")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if state.totalFoundBytes > 0 && !state.isScanning && !state.isCleaning {
                        Button {
                            SoundHaptics.clean()
                            state.cleanSelected()
                        } label: {
                            Label("Sposta nel Cestino", systemImage: "trash")
                        }
                        .help("Sposta gli elementi selezionati nel Cestino (⌘⌫)")
                    }

                    Button {
                        SoundHaptics.tap()
                        state.startScanAll()
                    } label: {
                        Label(state.isScanning ? "Scansione..." : "Scansiona", systemImage: "arrow.clockwise")
                    }
                    .disabled(state.isScanning || state.isCleaning)
                    .help("Scansiona Mac (⌘R)")
                }
            }
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
