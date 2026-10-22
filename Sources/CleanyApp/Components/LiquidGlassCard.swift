import SwiftUI

/// macOS Native Liquid Glass Card View and View Modifier.
/// Adapts gracefully with `Glass.regular` on macOS 26+ and native `.ultraThinMaterial` on macOS 15+.
public struct LiquidGlassCardModifier: ViewModifier {
    public let cornerRadius: CGFloat
    public let tintColor: Color?
    public let isInteractive: Bool

    public init(cornerRadius: CGFloat = 18, tintColor: Color? = nil, isInteractive: Bool = true) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.isInteractive = isInteractive
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
#if HAS_MACOS26_GLASS
        if #available(macOS 26.0, *) {
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
        } else {
            fallbackBody(content: content)
        }
#else
        fallbackBody(content: content)
#endif
    }

    @ViewBuilder
    private func fallbackBody(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(tintColor?.opacity(0.1) ?? Color.clear)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
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
    /// Applies native macOS Liquid Glass effect with specular edge refraction.
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

    /// Modern Liquid Glass prominent button style with graceful fallback to borderedProminent.
    @ViewBuilder
    func cleanyGlassProminent(tint: Color? = nil) -> some View {
#if HAS_MACOS26_GLASS
        if #available(macOS 26.0, *) {
            if let tint = tint {
                self.buttonStyle(.glassProminent).tint(tint)
            } else {
                self.buttonStyle(.glassProminent)
            }
        } else {
            if let tint = tint {
                self.buttonStyle(.borderedProminent).tint(tint)
            } else {
                self.buttonStyle(.borderedProminent)
            }
        }
#else
        if let tint = tint {
            self.buttonStyle(.borderedProminent).tint(tint)
        } else {
            self.buttonStyle(.borderedProminent)
        }
#endif
    }

    /// Modern Liquid Glass button style with graceful fallback to bordered.
    @ViewBuilder
    func cleanyGlass() -> some View {
#if HAS_MACOS26_GLASS
        if #available(macOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
#else
        self.buttonStyle(.bordered)
#endif
    }
}
