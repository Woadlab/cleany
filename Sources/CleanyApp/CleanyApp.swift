import SwiftUI
import CleanyCore

@main
struct CleanyApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(state: state)
                    .navigationSplitViewColumnWidth(min: 230, ideal: 245, max: 280)
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
            .frame(minWidth: 980, minHeight: 680)
            .navigationTitle("Cleany")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    if state.totalFoundBytes > 0 && !state.isScanning && !state.isCleaning {
                        Button {
                            SoundHaptics.tap()
                            state.cleanSelected()
                        } label: {
                            Label("Clean to Trash", systemImage: "trash")
                        }
                        .help("Clean selected items to Trash (⌘⌫)")
                    }

                    Button {
                        SoundHaptics.tap()
                        state.startScanAll()
                    } label: {
                        Label(state.isScanning ? "Scanning..." : "Scan", systemImage: "arrow.clockwise")
                    }
                    .disabled(state.isScanning || state.isCleaning)
                    .help("Scan Mac (⌘R)")
                }
            }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Start Full Scan") {
                    state.startScanAll()
                }
                .keyboardShortcut("r", modifiers: .command)
            }

            CommandMenu("Clean") {
                Button("Clean to Trash") {
                    state.cleanSelected()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(state.totalFoundBytes == 0 || state.isCleaning)
            }
        }
    }
}
