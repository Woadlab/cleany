import SwiftUI
import CleanyCore

/// Ultra-premium CleanMyMac 5 / Apple Intelligence-grade Glass Lens hero centerpiece.
/// Features multi-layer specular glass, precision tick marks, luminous segmented neon arcs,
/// and live telemetry choreography.
public struct ScanningGaugeView: View {
    public let isScanning: Bool
    public let hasScanned: Bool
    public let formattedSize: String
    public let itemCount: Int
    public let currentPath: String?
    public let categorySizes: [(JunkCategory, UInt64)]

    @LocalVar private var rotation: Double = 0
    @LocalVar private var pulse: Bool = false
    @LocalVar private var levitate: CGFloat = 0

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
        VStack(spacing: 16) {
            ZStack {
                // Layer 1: Ambient Luminous Aura
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                auraColor.opacity(isScanning ? 0.28 : (hasScanned && itemCount > 0 ? 0.20 : 0.12)),
                                auraColor.opacity(0.04),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .scaleEffect(pulse ? 1.06 : 0.96)
                    .animation(
                        isScanning ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) :
                                     .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                        value: pulse
                    )

                // Layer 2: Precision Outer Chrono Tick Ring (60 radial ticks)
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    .frame(width: 254, height: 254)

                ForEach(0..<48) { tick in
                    Rectangle()
                        .fill(Color.white.opacity(tick % 4 == 0 ? 0.25 : 0.08))
                        .frame(width: tick % 4 == 0 ? 1.5 : 1, height: tick % 4 == 0 ? 6 : 3)
                        .offset(y: -123)
                        .rotationEffect(.degrees(Double(tick) * (360.0 / 48.0)))
                }

                // Layer 3: Outer Glass Track
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 10
                    )
                    .frame(width: 232, height: 232)

                // Layer 4: Active Energy Ring
                if isScanning {
                    // Sweeping Laser Radar Ring
                    Circle()
                        .trim(from: 0.05, to: 0.75)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    Color.cyan.opacity(0.0),
                                    Color.cyan.opacity(0.4),
                                    Color.blue,
                                    Color.purple
                                ]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 232, height: 232)
                        .rotationEffect(.degrees(rotation))
                } else if hasScanned && totalBytes > 0 {
                    // Multi-Segmented Luminous Neon Arcs
                    let segments = calculateSegments()
                    ForEach(0..<segments.count, id: \.self) { idx in
                        let seg = segments[idx]
                        Circle()
                            .trim(from: seg.start, to: seg.end)
                            .stroke(
                                seg.color,
                                style: StrokeStyle(lineWidth: 10, lineCap: .butt)
                            )
                            .frame(width: 232, height: 232)
                            .rotationEffect(.degrees(-90))
                            .shadow(color: seg.color.opacity(0.4), radius: 6, x: 0, y: 0)
                    }
                } else if hasScanned && itemCount == 0 {
                    // Spotless Emerald Ring
                    Circle()
                        .stroke(
                            LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .frame(width: 232, height: 232)
                        .shadow(color: Color.green.opacity(0.5), radius: 8, x: 0, y: 0)
                }

                // Layer 5: Inner Frosted Glass Lens
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.13, blue: 0.18).opacity(0.85),
                                Color(red: 0.07, green: 0.075, blue: 0.11).opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 206, height: 206)
                    .overlay(
                        // Specular Glass Edge Highlight
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.05),
                                        Color.black.opacity(0.4)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)

                // Layer 6: Centerpiece Telemetry Content
                VStack(spacing: 6) {
                    if isScanning {
                        Image(systemName: "sparkle.magnifyingglass")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: Color.cyan.opacity(0.6), radius: 8)

                        Text("ANALYZING")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2.5)
                            .foregroundStyle(.white.opacity(0.9))

                        Text("Computing sizes...")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.45))

                    } else if hasScanned && itemCount > 0 {
                        // Split size number and unit
                        VStack(spacing: 2) {
                            Text(formattedSize)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0.9)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .contentTransition(.numericText())

                            Text("RECLAIMABLE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2.2)
                                .foregroundStyle(Color.cyan.opacity(0.9))

                            Text("\(itemCount) safe items")
                                .font(.system(size: 11.5, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.top, 2)
                        }

                    } else if hasScanned && itemCount == 0 {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: Color.green.opacity(0.5), radius: 10)

                        Text("SPOTLESS")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(2.5)
                            .foregroundStyle(.white.opacity(0.95))

                        Text("Mac is in peak shape")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.5))

                    } else {
                        // Idle Ready State
                        Image(systemName: "sparkles")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.5, green: 0.6, blue: 1.0), Color(red: 0.75, green: 0.45, blue: 0.98)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.purple.opacity(0.5), radius: 10)
                            .offset(y: levitate)

                        Text("SMART CARE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2.4)
                            .foregroundStyle(.white.opacity(0.95))

                        Text("5 Modules Armed")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
            }
            .frame(width: 270, height: 270)
            .onAppear {
                pulse = true
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    levitate = -5
                }
                if isScanning {
                    withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
            }
            .onChange(of: isScanning) { _, scanning in
                if scanning {
                    withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                } else {
                    rotation = 0
                }
            }

            // Real-Time Live Telemetry Glass Pill
            if isScanning, let path = currentPath, !path.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.mini)

                    Text(path)
                        .font(.system(size: 10.5, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 420)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1))
                )
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
    }

    private var auraColor: Color {
        if isScanning {
            return Color.cyan
        } else if hasScanned && totalBytes > 0 {
            return Color.blue
        } else if hasScanned && itemCount == 0 {
            return Color.green
        } else {
            return Color(red: 0.45, green: 0.35, blue: 0.85)
        }
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
            return Color(red: 0.75, green: 0.35, blue: 0.95)
        case .developerJunk:
            return Color(red: 0.25, green: 0.55, blue: 0.98)
        case .systemJunk:
            return Color(red: 0.15, green: 0.75, blue: 0.75)
        case .appLeftovers:
            return Color(red: 0.98, green: 0.55, blue: 0.15)
        case .trashBins:
            return Color(red: 0.95, green: 0.28, blue: 0.32)
        }
    }
}
