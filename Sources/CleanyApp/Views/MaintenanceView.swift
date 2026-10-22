import SwiftUI
import CleanyCore

/// Native Apple HIG Maintenance View.
/// Form-based system maintenance routines with standard controls and SF Symbols.
public struct MaintenanceView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manutenzione di Sistema")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Routine native di ottimizzazione macOS eseguite al 100% in locale senza daemon o processi in background.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)

                // Grouped Maintenance Tasks
                VStack(spacing: 0) {
                    ForEach(Array(MaintenanceTask.allCases.enumerated()), id: \.element.id) { index, task in
                        taskRow(task: task)

                        if index < MaintenanceTask.allCases.count - 1 {
                            Divider()
                                .padding(.leading, 54)
                        }
                    }
                }
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 0.5)
                )
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private func taskRow(task: MaintenanceTask) -> some View {
        let isRunning = state.runningTasks.contains(task)
        let result = state.maintenanceResults[task]

        HStack(spacing: 14) {
            // Task Icon
            Image(systemName: task.systemImage)
                .font(.system(size: 20))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .frame(width: 32, height: 32)

            // Description
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
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
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Run Button
            if isRunning {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("In corso...")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
            } else {
                Button("Esegui") {
                    SoundHaptics.tap()
                    state.runMaintenanceTask(task)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
