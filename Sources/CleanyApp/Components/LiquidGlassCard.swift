import SwiftUI

/// macOS 27 Native Liquid Glass Card View and View Modifier.
/// Combines `Glass.regular` interactive glass refraction with subtle specular borders
/// and fluid spring physics.
public struct LiquidGlassCardModifier: ViewModifier {
    public let cornerRadius: CGFloat
    public let tintColor: Color?
    public let isInteractive: Bool

    public init(cornerRadius: CGFloat = 18, tintColor: Color? = nil, isInteractive: Bool = true) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        let glass: Glass = {
            var g = Glass.regular
            if let tint = tintColor {
                g = g.tint(tint)
            }
            if isInteractive {
                g = g.interactive()
            }
            return g
        }()

        content
            .glassEffect(glass, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

public extension View {
    /// Applies native macOS 27 Liquid Glass effect with specular edge refraction.
    func liquidGlass(
        cornerRadius: CGFloat = 18,
        tint: Color? = nil,
        isInteractive: Bool = true
    ) -> some View {
        self.modifier(LiquidGlassCardModifier(
            cornerRadius: cornerRadius,
            tintColor: tint,
            isInteractive: isInteractive
        ))
    }
}
