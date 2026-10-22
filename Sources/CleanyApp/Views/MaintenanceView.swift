import SwiftUI
import CleanyCore

public struct MaintenanceView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System Maintenance")
                        .font(.system(size: 20, weight: .bold))

                    Text("Native macOS maintenance routines executed locally without background services.")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 12)

                VStack(spacing: 12) {
                    ForEach(MaintenanceTask.allCases) { task in
                        maintenanceCard(task: task)
                    }
                }
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private func maintenanceCard(task: MaintenanceTask) -> some View {
        let isRunning = state.runningTasks.contains(task)
        let result = state.maintenanceResults[task]

        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.10))
                    .frame(width: 40, height: 40)

                Image(systemName: task.systemImage)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold))

                Text(task.taskDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                if let res = result {
                    HStack(spacing: 4) {
                        Image(systemName: res.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(res.success ? .green : .orange)
                        Text(res.message)
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(res.success ? .green : .orange)
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
                        .frame(width: 64, height: 24)
                } else {
                    Text("Run")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 64, height: 24)
                }
            }
            .buttonStyle(.bordered)
            .disabled(isRunning)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
