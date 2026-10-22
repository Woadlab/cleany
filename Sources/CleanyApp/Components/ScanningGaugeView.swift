import SwiftUI
import CleanyCore

/// Ultra-refined macOS circular gauge with proportional multi-category segmented arcs,
/// ambient glow physics, and real-time live scan telemetry.
public struct ScanningGaugeView: View {
    public let isScanning: Bool
    public let hasScanned: Bool
    public let formattedSize: String
    public let itemCount: Int
    public let currentPath: String?
    public let categorySizes: [(JunkCategory, UInt64)]

    @LocalVar private var rotation: Double = 0
    @LocalVar private var isPulsing: Bool = false

    public init(
        isScanning: Bool,
        hasScanned: Bool,
        formattedSize: String,
        itemCount: Int,
        currentPath: String? = nil,
        categorySizes: [(JunkCategory, UInt64)] = []
    ) {
        self.isScanning = isScanning
        self.hasScanned = hasScanned
        self.formattedSize = formattedSize
        self.itemCount = itemCount
        self.currentPath = currentPath
        self.categorySizes = categorySizes
    }

    private var totalBytes: UInt64 {
        categorySizes.reduce(0) { $0 + $1.1 }
    }

    public var body: some View {
        VStack(spacing: 22) {
            ZStack {
                // Ambient dynamic glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                isScanning ? Color.blue.opacity(0.14) :
                                (hasScanned && itemCount > 0 ? Color.indigo.opacity(0.10) : Color.clear),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 140
                        )
                    )
                    .frame(width: 270, height: 270)
                    .scaleEffect(isPulsing ? 1.05 : 0.98)
                    .animation(
                        isScanning ? .easeInOut(duration: 1.4).repeatForever(autoreverses: true) : .default,
                        value: isPulsing
                    )

                // Outer subtle track
                Circle()
                    .stroke(Color.primary.opacity(0.05), lineWidth: 12)
                    .frame(width: 220, height: 220)

                if isScanning {
                    // Precision sweeping radar ring
                    Circle()
                        .trim(from: 0.05, to: 0.8)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.05),
                                    Color.cyan.opacity(0.8),
                                    Color.blue
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(rotation))
                        .onAppear {
                            isPulsing = true
                            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                } else if hasScanned && totalBytes > 0 {
                    // Segmented macOS Activity-style multi-color ring
                    let segments = calculateSegments()
                    ForEach(0..<segments.count, id: \.self) { idx in
                        let seg = segments[idx]
                        Circle()
                            .trim(from: seg.start, to: seg.end)
                            .stroke(
                                seg.color,
                                style: StrokeStyle(lineWidth: 12, lineCap: .butt)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                    }
                } else if hasScanned && itemCount == 0 {
                    // Clean emerald ring
                    Circle()
                        .stroke(Color.green.opacity(0.75), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 220, height: 220)
                }

                // Center Information
                VStack(spacing: 8) {
                    if isScanning {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                            )

                        Text("Deep Scanning...")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("Inspecting caches & models")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)

                    } else if hasScanned && itemCount > 0 {
                        Text(formattedSize)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())

                        HStack(spacing: 4) {
                            Text("\(itemCount)")
                                .fontWeight(.semibold)
                            Text("safe items found")
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)

                    } else if hasScanned && itemCount == 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.green)

                        Text("Spotless")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("Your Mac is running clean")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)

                    } else {
                        Image(systemName: "sparkles")
                            .font(.system(size: 38, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )

                        Text("Smart Care")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)

                        Text("100% Local • Zero Telemetry")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Real-time active telemetry ticker
            if isScanning, let path = currentPath, !path.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.mini)

                    Text(path)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 440)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.primary.opacity(0.04))
                .clipShape(Capsule())
                .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
    }

    private struct ArcSegment {
        let start: CGFloat
        let end: CGFloat
        let color: Color
    }

    private func calculateSegments() -> [ArcSegment] {
        guard totalBytes > 0 else { return [] }
        var result: [ArcSegment] = []
        var current: CGFloat = 0

        for (cat, size) in categorySizes {
            guard size > 0 else { continue }
            let fraction = CGFloat(size) / CGFloat(totalBytes)
            let next = min(1.0, current + fraction)
            result.append(ArcSegment(start: current, end: next, color: colorForCategory(cat)))
            current = next
        }

        return result
    }

    private func colorForCategory(_ cat: JunkCategory) -> Color {
        switch cat {
        case .aiClutter:
            return .purple
        case .developerJunk:
            return .blue
        case .systemJunk:
            return .teal
        case .appLeftovers:
            return .orange
        case .trashBins:
            return .red
        }
    }
}
