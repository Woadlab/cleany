import SwiftUI
import CleanyCore

/// Native macOS 27 Maintenance View.
/// Features Liquid Glass control platters for system maintenance routines
/// executed 100% locally with zero background daemons.
public struct MaintenanceView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            // macOS 27 Ambient Fluid Mesh Atmosphere
            LiquidGlassBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Platter
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manutenzione di Sistema")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("Routine native di ottimizzazione macOS eseguite al 100% in locale con permessi standard e zero daemon.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .liquidGlass(cornerRadius: 18, tint: Color.accentColor.opacity(0.06), isInteractive: false)
                    .padding(.top, 20)

                    // Tasks Grid
                    VStack(spacing: 12) {
                        ForEach(MaintenanceTask.allCases) { task in
                            maintenanceCard(task: task)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .frame(maxWidth: 860)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func maintenanceCard(task: MaintenanceTask) -> some View {
        let isRunning = state.runningTasks.contains(task)
        let result = state.maintenanceResults[task]

        HStack(spacing: 16) {
            // Task Icon in a Glass Droplet
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(Color.accentColor.opacity(0.35), lineWidth: 1))

                Image(systemName: task.systemImage)
                    .font(.system(size: 19, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
            }

            // Description
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text(task.taskDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let res = result {
                    HStack(spacing: 5) {
                        Image(systemName: res.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(res.success ? Color.green : Color.orange)
                            .font(.caption2)

                        Text(res.message)
                            .foregroundStyle(res.success ? Color.green : Color.orange)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Run Button with native macOS 27 glass button style
            if isRunning {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("In corso...")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .liquidGlass(cornerRadius: 12, tint: Color.primary.opacity(0.04), isInteractive: false)
            } else {
                Button {
                    SoundHaptics.tap()
                    state.runMaintenanceTask(task)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 10))
                        Text("Esegui")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                }
                .buttonStyle(.glassProminent)
                .clipShape(Capsule())
            }
        }
        .padding(18)
        .liquidGlass(cornerRadius: 20, tint: Color.primary.opacity(0.04), isInteractive: true)
    }
}
