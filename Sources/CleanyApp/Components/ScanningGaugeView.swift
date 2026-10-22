import SwiftUI

/// Animated circular progress ring showing scan and cleaning status.
public struct ScanningGaugeView: View {
    public let isScanning: Bool
    public let formattedSize: String
    public let itemCount: Int

    @LocalVar private var rotation: Double = 0

    public init(isScanning: Bool, formattedSize: String, itemCount: Int) {
        self.isScanning = isScanning
        self.formattedSize = formattedSize
        self.itemCount = itemCount
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.primary.opacity(0.06), lineWidth: 16)
                .frame(width: 220, height: 220)

            if isScanning {
                // Spinning active gradient
                Circle()
                    .trim(from: 0.1, to: 0.85)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.blue, .purple, .pink, .blue]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            } else {
                // Completed static colored ring
                Circle()
                    .trim(from: 0, to: itemCount > 0 ? 1 : 0.05)
                    .stroke(
                        LinearGradient(
                            colors: itemCount > 0 ? [.blue, .teal] : [.secondary.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: itemCount)
            }

            // Center metric text
            VStack(spacing: 6) {
                if isScanning {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.tint)

                    Text("Scanning...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                } else if itemCount > 0 {
                    Text(formattedSize)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())

                    Text("\(itemCount) item(s) found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)

                    Text("Mac is Spotless")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
    }
}
