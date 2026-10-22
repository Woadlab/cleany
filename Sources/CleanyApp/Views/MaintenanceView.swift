import SwiftUI
import CleanyCore

public struct MaintenanceView: View {
    @ObservedObject var state: AppState

    public init(state: AppState) {
        self.state = state
    }

    public var body: some View {
        ZStack {
            AtmosphericBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("System Maintenance")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Native macOS optimization routines executed 100% locally with zero background daemons.")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                    .padding(.top, 16)

                    // Task Cards List
                    VStack(spacing: 12) {
                        ForEach(MaintenanceTask.allCases) { task in
                            maintenanceCard(task: task)
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
    }

    @ViewBuilder
    private func maintenanceCard(task: MaintenanceTask) -> some View {
        let isRunning = state.runningTasks.contains(task)
        let result = state.maintenanceResults[task]

        HStack(spacing: 16) {
            // Task Icon Bezel
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.3), Color.indigo.opacity(0.1)],
                            center: .center,
                            startRadius: 2,
                            endRadius: 22
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(Circle().stroke(Color.blue.opacity(0.35), lineWidth: 1))
                    .shadow(color: Color.blue.opacity(0.2), radius: 6)

                Image(systemName: task.systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.cyan)
            }

            // Description
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)

                Text(task.taskDescription)
                    .font(.system(size: 11.5))
                    .foregroundStyle(.white.opacity(0.5))

                if let res = result {
                    HStack(spacing: 5) {
                        Image(systemName: res.success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(res.success ? Color.green : Color.orange)
                        Text(res.message)
                            .foregroundStyle(res.success ? Color.green.opacity(0.9) : Color.orange.opacity(0.9))
                    }
                    .font(.system(size: 11, weight: .medium))
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Run Action Button
            Button {
                SoundHaptics.tap()
                state.runMaintenanceTask(task)
            } label: {
                if isRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Running")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .frame(width: 84, height: 32)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                } else {
                    HStack(spacing: 6) {
                        Text("Run")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(.white)
                        Image(systemName: "play.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .frame(width: 84, height: 32)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue, Color.indigo],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 2)
                }
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(isRunning)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 0.08, green: 0.085, blue: 0.12).opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
                .padding(0.5)
        )
    }
}
