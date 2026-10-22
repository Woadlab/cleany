import SwiftUI

/// Modern macOS 27 ambient fluid background utilizing native `MeshGradient`.
/// Provides ethereal, luminous fluid color fields that shine through Liquid Glass layers
/// and adapt dynamically to Dark and Light appearances across the entire window frame.
public struct LiquidGlassBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @LocalVar private var isBreathing: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // Dynamic Base Layer
            (colorScheme == .dark
                ? Color(red: 0.06, green: 0.07, blue: 0.11)
                : Color(red: 0.94, green: 0.95, blue: 0.98)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

            // Native macOS 27 MeshGradient Fluid Field (Fully Expanded)
            MeshGradient(
                width: 3,
                height: 3,
                locations: .points([
                    SIMD2<Float>(0.0, 0.0), SIMD2<Float>(0.5, 0.0), SIMD2<Float>(1.0, 0.0),
                    SIMD2<Float>(0.0, isBreathing ? 0.45 : 0.55), SIMD2<Float>(isBreathing ? 0.55 : 0.45, 0.5), SIMD2<Float>(1.0, isBreathing ? 0.55 : 0.45),
                    SIMD2<Float>(0.0, 1.0), SIMD2<Float>(0.5, 1.0), SIMD2<Float>(1.0, 1.0)
                ]),
                colors: .colors(colorScheme == .dark ? darkMeshColors : lightMeshColors)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .blur(radius: 60)
            .ignoresSafeArea()
            .opacity(colorScheme == .dark ? 0.55 : 0.40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 9.0).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }

    private var darkMeshColors: [Color] {
        [
            Color(red: 0.18, green: 0.12, blue: 0.45), // Deep Violet
            Color(red: 0.08, green: 0.22, blue: 0.48), // Sapphire
            Color(red: 0.05, green: 0.35, blue: 0.40), // Dark Teal

            Color(red: 0.25, green: 0.10, blue: 0.40), // Magenta accent
            Color.clear,                              // Breathing center
            Color(red: 0.06, green: 0.28, blue: 0.45), // Cyan accent

            Color(red: 0.10, green: 0.15, blue: 0.35), // Indigo base
            Color(red: 0.05, green: 0.20, blue: 0.35), // Deep Ocean
            Color(red: 0.16, green: 0.10, blue: 0.38)  // Royal Violet
        ]
    }

    private var lightMeshColors: [Color] {
        [
            Color(red: 0.85, green: 0.88, blue: 0.98), // Soft periwinkle
            Color(red: 0.82, green: 0.92, blue: 0.97), // Soft sky blue
            Color(red: 0.84, green: 0.96, blue: 0.94), // Mint/Ice

            Color(red: 0.90, green: 0.86, blue: 0.96), // Soft lavender
            Color.clear,
            Color(red: 0.86, green: 0.94, blue: 0.98),

            Color(red: 0.88, green: 0.90, blue: 0.98),
            Color(red: 0.85, green: 0.95, blue: 0.98),
            Color(red: 0.92, green: 0.88, blue: 0.97)
        ]
    }
}
