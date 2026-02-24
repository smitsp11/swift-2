import SwiftUI

/// Screen 1 — Launch Screen
/// Dark canvas with a procedural diya glow, ambient reactivity, and two CTAs.
struct LaunchScreen: View {
    let onStartCycle: () -> Void
    let onEnterCircle: () -> Void

    @EnvironmentObject var rhythmEngine: RhythmEngine
    @State private var diyaGlowBoost: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            // Background: near-black
            Color(red: 0.05, green: 0.02, blue: 0.0)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("AVART")
                        .font(.system(size: 48, weight: .bold, design: .default))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityLabel("Avart")

                    Text("The Rhythmic Geometry of Navratri")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color(red: 0.72, green: 0.53, blue: 0.04))
                        .accessibilityLabel("The Rhythmic Geometry of Navratri")
                }
                .padding(.bottom, 80)

                // Diya — procedural glowing circle
                ZStack {
                    PulsingGlow(
                        color: Color(red: 1.0, green: 0.55, blue: 0.0),
                        baseRadius: 80 + diyaGlowBoost
                    )
                    .frame(width: 240, height: 240)
                }
                .accessibilityLabel("Glowing diya lamp, reacting to ambient sound")

                Spacer()

                // CTA Buttons
                HStack(spacing: 24) {
                    // Secondary: Start the Cycle (passive mode)
                    Button(action: onStartCycle) {
                        Text("Start the Cycle")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                    .accessibilityLabel("Start the Cycle")
                    .accessibilityHint("Watch a pre-programmed Rangoli draw itself")

                    // Primary: Enter the Circle (active mode)
                    Button(action: onEnterCircle) {
                        Text("Enter the Circle")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                    }
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 1.0, green: 0.55, blue: 0.0), lineWidth: 1)
                    )
                    .accessibilityLabel("Enter the Circle")
                    .accessibilityHint("Choose a night and create your own Rangoli with claps or taps")
                }
                .padding(.bottom, 60)
            }
        }
        .onChange(of: rhythmEngine.currentAmplitude) { _, newValue in
            // Ambient reactivity: spike glow on transient
            if newValue > 0.15 {
                withAnimation(.easeOut(duration: 0.3)) {
                    diyaGlowBoost = CGFloat(newValue) * 40
                }
                // Return to baseline
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        diyaGlowBoost = 0
                    }
                }
            }
        }
    }
}
