import SwiftUI

/// Animated atmospheric background featuring floating radial mesh glows and deep obsidian glass,
/// creating the signature CleanMyMac / Apple Intelligence ethereal depth.
public struct AtmosphericBackgroundView: View {
    @LocalVar private var animateGlow: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // Base obsidian black
            Color(red: 0.04, green: 0.045, blue: 0.07)
                .ignoresSafeArea()

            // Top-left ambient indigo orb
            RadialGradient(
                colors: [
                    Color(red: 0.22, green: 0.18, blue: 0.45).opacity(0.35),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: animateGlow ? 480 : 420
            )
            .ignoresSafeArea()
            .offset(x: animateGlow ? 20 : -20, y: animateGlow ? -10 : 20)

            // Center-right electric cyan/teal glow
            RadialGradient(
                colors: [
                    Color(red: 0.05, green: 0.35, blue: 0.55).opacity(0.25),
                    Color.clear
                ],
                center: .trailing,
                startRadius: 60,
                endRadius: animateGlow ? 520 : 460
            )
            .ignoresSafeArea()
            .offset(x: animateGlow ? -30 : 30, y: animateGlow ? 40 : -20)

            // Bottom-center magenta/purple accent orb
            RadialGradient(
                colors: [
                    Color(red: 0.35, green: 0.10, blue: 0.40).opacity(0.20),
                    Color.clear
                ],
                center: .bottom,
                startRadius: 80,
                endRadius: animateGlow ? 560 : 500
            )
            .ignoresSafeArea()

            // Subtle dark vignette overlay
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.clear,
                    Color.black.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                animateGlow.toggle()
            }
        }
    }
}
