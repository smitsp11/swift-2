import SwiftUI

/// Reusable glass card component used for Night selection cards, Rhythm Bar,
/// and Reflection card. Applies Liquid Glass aesthetic over the animated gradient.
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    init(cornerRadius: CGFloat = 24, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

/// Ambient pulsing glow effect used on the launch screen diya
struct PulsingGlow: View {
    let color: Color
    let baseRadius: CGFloat
    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let pulse = sin(time * 0.8 * 2 * .pi) * 0.5 + 0.5 // 0.8Hz sinusoidal

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let glowRadius = baseRadius + CGFloat(pulse) * 20

                // Outer glow
                let outerGradient = Gradient(colors: [
                    color.opacity(0.0),
                    color.opacity(0.05),
                    color.opacity(0.15 + pulse * 0.1),
                    color.opacity(0.4 + pulse * 0.2),
                    color.opacity(0.8)
                ])
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - glowRadius,
                        y: center.y - glowRadius,
                        width: glowRadius * 2,
                        height: glowRadius * 2
                    )),
                    with: .radialGradient(
                        outerGradient,
                        center: center,
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                )

                // Inner bright core
                let coreRadius = baseRadius * 0.3
                let coreGradient = Gradient(colors: [
                    .white.opacity(0.9),
                    color.opacity(0.95),
                    color.opacity(0.0)
                ])
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x - coreRadius,
                        y: center.y - coreRadius,
                        width: coreRadius * 2,
                        height: coreRadius * 2
                    )),
                    with: .radialGradient(
                        coreGradient,
                        center: center,
                        startRadius: 0,
                        endRadius: coreRadius
                    )
                )
            }
        }
        .accessibilityHidden(true)
    }
}

/// Shimmer loading animation for the reflection screen
struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    .clear,
                    .white.opacity(0.15),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.6)
            .offset(x: phase * geo.size.width)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.5
                }
            }
        }
        .clipped()
    }
}
