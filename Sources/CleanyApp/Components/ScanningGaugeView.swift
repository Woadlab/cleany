import SwiftUI
import CleanyCore

/// Modern, refined circular gauge displaying system scan state.
public struct ScanningGaugeView: View {
    public let isScanning: Bool
    public let hasScanned: Bool
    public let formattedSize: String
    public let itemCount: Int
    public let currentPath: String?

    @LocalVar private var rotation: Double = 0

    public init(
        isScanning: Bool,
        hasScanned: Bool,
        formattedSize: String,
        itemCount: Int,
        currentPath: String? = nil
    ) {
        self.isScanning = isScanning
        self.hasScanned = hasScanned
        self.formattedSize = formattedSize
        self.itemCount = itemCount
        self.currentPath = currentPath
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background ambient glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isScanning ? Color.blue.opacity(0.12) :
                                (hasScanned && itemCount > 0 ? Color.indigo.opacity(0.08) : Color.clear),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 130
                        )
                    )
                    .frame(width: 250, height: 250)

                // Outer track
                Circle()
                    .stroke(Color.primary.opacity(0.06), lineWidth: 10)
                    .frame(width: 210, height: 210)

                if isScanning {
                    // Refined scanning sweep ring
                    Circle()
                        .trim(from: 0.05, to: 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.1),
                                    Color.cyan,
                                    Color.blue
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 210, height: 210)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                } else if hasScanned && itemCount > 0 {
                    // Static clean highlight ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 210, height: 210)
                        .shadow(color: Color.blue.opacity(0.25), radius: 8, x: 0, y: 4)
                } else if hasScanned && itemCount == 0 {
                    // Spotless green accent ring
                    Circle()
                        .stroke(Color.green.opacity(0.8), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 210, height: 210)
                }

                // Center Information
                VStack(spacing: 8) {
                    if isScanning {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                            )
                            .symbolEffect(.pulse, options: .repeating)

                        Text("Analyzing Storage")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("Finding junk & AI clutter...")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                    } else if hasScanned && itemCount > 0 {
                        Text(formattedSize)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        Text("\(itemCount) items reclaimable")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)

                    } else if hasScanned && itemCount == 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.green)

                        Text("Mac is Spotless")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Zero junk detected")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                    } else {
                        // Initial Ready State
                        Image(systemName: "sparkles")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text("Ready to Clean")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text("Safe • Local • 100% Private")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Real-time active scan path indicator
            if isScanning, let path = currentPath, !path.isEmpty {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.mini)

                    Text(path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 420)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.04))
                .clipShape(Capsule())
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8)
    }
}
