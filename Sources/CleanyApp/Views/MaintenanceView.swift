import SwiftUI
import CleanyCore

public struct MaintenanceView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Maintenance")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Native macOS maintenance routines executed 100% locally with zero external daemons.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                VStack(spacing: 14) {
                    ForEach(MaintenanceTask.allCases) { task in
                        maintenanceCard(task: task)
                    }
                }
            }
            .padding(28)
        }
    }

    @ViewBuilder
    private func maintenanceCard(task: MaintenanceTask) -> some View {
        let isRunning = state.runningTasks.contains(task)
        let result = state.maintenanceResults[task]

        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: task.systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.headline)

                Text(task.taskDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let res = result {
                    HStack(spacing: 4) {
                        Image(systemName: res.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(res.success ? .green : .orange)
                        Text(res.message)
                    }
                    .font(.caption2)
                    .padding(.top, 2)
                }
            }

            Spacer()

            Button {
                state.runMaintenanceTask(task)
            } label: {
                if isRunning {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 60)
                } else {
                    Text("Run")
                        .fontWeight(.medium)
                        .frame(width: 60)
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRunning)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
