import SwiftUI
import AVFoundation

/// Screen 2 — Night Selection Screen
/// Horizontal scroll of three glass cards, each representing a Navratri night.
struct NightSelectionScreen: View {
    let onNightSelected: (Night) -> Void

    @State private var selectedNight: Night? = nil
    @State private var backgroundNight: Night = .night1
    @State private var cardScale: [Night: CGFloat] = [:]
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            // Animated background gradient
            backgroundNight.backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: backgroundNight)

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose Your Night")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Each night carries a different goddess, rhythm, and geometry")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 40)
                .accessibilityElement(children: .combine)

                // Night cards — horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(Night.allCases) { night in
                            NightCard(
                                night: night,
                                isSelected: selectedNight == night,
                                scale: cardScale[night] ?? 1.0
                            )
                            .onTapGesture {
                                selectNight(night)
                            }
                            .accessibilityLabel("Night \(night.rawValue), \(night.goddessName)")
                            .accessibilityHint("Double tap to select this night")
                            .accessibilityAddTraits(selectedNight == night ? .isSelected : [])
                        }
                    }
                    .padding(.horizontal, 40)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)

                // Continue button (appears after selection)
                if let night = selectedNight {
                    Button {
                        onNightSelected(night)
                    } label: {
                        HStack {
                            Text("Begin Night \(night.rawValue)")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(night.primaryColor, lineWidth: 1)
                        )
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .accessibilityLabel("Begin Night \(night.rawValue)")
                }

                Spacer()
            }
        }
    }

    private func selectNight(_ night: Night) {
        selectedNight = night

        // Background transition
        if reduceMotion {
            backgroundNight = night
        } else {
            withAnimation(.easeInOut(duration: 0.6)) {
                backgroundNight = night
            }
        }

        // Card scale animation
        if !reduceMotion {
            withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
                cardScale[night] = 1.05
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                    cardScale[night] = 1.0
                }
            }
        }

        // Play 3-second synthesized rhythm preview
        playRhythmPreview(for: night)
    }

    /// Synthesized click preview — no audio files
    private func playRhythmPreview(for night: Night) {
        // Use system sounds for a simple rhythmic preview
        let interval = 60.0 / 90.0  // 90 BPM
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                AudioServicesPlaySystemSound(1104) // Subtle tick sound
            }
        }
    }
}

/// Individual night selection card
struct NightCard: View {
    let night: Night
    let isSelected: Bool
    let scale: CGFloat

    var body: some View {
        GlassCard(cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 12) {
                // Gujarati goddess name
                Text(night.goddessGujarati)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))

                // English name
                Text(night.goddessName)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                // Cultural attributes
                Text(night.culturalAttributes)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(2)

                // Color swatch strip
                HStack(spacing: 0) {
                    Rectangle().fill(night.primaryColor)
                    Rectangle().fill(night.secondaryColor)
                    Rectangle().fill(night.accentColor)
                }
                .frame(height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 4))

                // Symmetry info
                HStack {
                    Text("\(night.defaultSymmetryFold)-fold symmetry")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    Spacer()
                }
            }
            .padding(20)
            .frame(width: 260, height: 360)
            .overlay(alignment: .bottomTrailing) {
                // Large ambient night number
                Text("\(night.rawValue)")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundStyle(.white.opacity(0.05))
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isSelected ? night.primaryColor.opacity(0.6) : .clear, lineWidth: 2)
        )
        .scaleEffect(scale)
    }
}
