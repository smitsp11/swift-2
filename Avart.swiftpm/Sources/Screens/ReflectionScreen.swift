import SwiftUI

/// Screen 4 — Reflection Screen
/// Displays the frozen mandala alongside an AI-generated (or fallback) poem.
struct ReflectionScreen: View {
    let sessionData: SessionData
    let frozenStrokes: [PolarStroke]
    let onNewNight: () -> Void

    @State private var reflection: ReflectionGenerator.NightReflection?
    @State private var isGenerating = true
    @State private var glowOpacity: Double = 0.6
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private let generator = ReflectionGenerator()

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.03, green: 0.02, blue: 0.01)
                .ignoresSafeArea()

            GeometryReader { geo in
                let isLandscape = geo.size.width > geo.size.height

                if isLandscape {
                    HStack(spacing: 0) {
                        mandalaView
                            .frame(width: geo.size.width * 0.55)
                        reflectionCard
                            .frame(width: geo.size.width * 0.45)
                            .padding(24)
                    }
                } else {
                    VStack(spacing: 0) {
                        mandalaView
                            .frame(height: geo.size.height * 0.5)
                        reflectionCard
                            .padding(24)
                    }
                }
            }
        }
        .task {
            await generateReflection()
        }
    }

    // MARK: - Mandala View

    private var mandalaView: some View {
        ZStack {
            // Frozen mandala
            Canvas { context, size in
                SymmetryRenderer.draw(
                    strokes: frozenStrokes,
                    symmetryFold: sessionData.symmetryFold,
                    in: &context,
                    size: size
                )
            }

            // Pulsing glow overlay
            if !reduceMotion {
                PulsingGlow(
                    color: sessionData.night.primaryColor,
                    baseRadius: 150
                )
                .opacity(glowOpacity * 0.3)
                .allowsHitTesting(false)
            }
        }
        .accessibilityLabel("Your completed Rangoli mandala for Night \(sessionData.night.rawValue)")
    }

    // MARK: - Reflection Card

    private var reflectionCard: some View {
        GlassCard(cornerRadius: 24) {
            VStack(spacing: 24) {
                if isGenerating {
                    // Loading state with shimmer
                    VStack(spacing: 16) {
                        Text("Reflecting...")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.6))

                        ShimmerView()
                            .frame(height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(32)
                } else if let reflection = reflection {
                    VStack(spacing: 20) {
                        // Evocative word
                        Text(reflection.word)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(red: 0.72, green: 0.53, blue: 0.04))
                            .accessibilityLabel("Word: \(reflection.word)")

                        // Poem
                        Text(reflection.poem)
                            .font(.body)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .accessibilityLabel("Poem: \(reflection.poem)")

                        Divider()
                            .background(.white.opacity(0.2))

                        // Session stats
                        HStack(spacing: 24) {
                            statBadge(value: "\(sessionData.totalBeats)", label: "Beats")
                            statBadge(value: "\(Int(sessionData.averageBPM))", label: "BPM")
                            statBadge(value: "\(sessionData.symmetryFold)×", label: "Symmetry")
                            statBadge(
                                value: "\(Int(sessionData.durationSeconds))s",
                                label: "Duration"
                            )
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Session: \(sessionData.totalBeats) beats, \(Int(sessionData.averageBPM)) BPM, \(sessionData.symmetryFold)-fold symmetry, \(Int(sessionData.durationSeconds)) seconds")

                        // Action buttons
                        HStack(spacing: 16) {
                            Button {
                                exportToPhotos()
                            } label: {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Save to Photos")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .accessibilityLabel("Save creation to Photos")

                            Button {
                                onNewNight()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("New Night")
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    sessionData.night.primaryColor,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            .accessibilityLabel("Start a new night")
                        }
                    }
                    .padding(32)
                }
            }
        }
    }

    private func statBadge(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    // MARK: - Actions

    private func generateReflection() async {
        isGenerating = true
        let result = await generator.generate(from: sessionData)
        withAnimation(.easeIn(duration: 0.5)) {
            reflection = result
            isGenerating = false
        }
    }

    @MainActor
    private func exportToPhotos() {
        // Create a renderer for the mandala
        let renderer = ImageRenderer(content:
            ZStack {
                Color.black
                Canvas { context, size in
                    SymmetryRenderer.draw(
                        strokes: frozenStrokes,
                        symmetryFold: sessionData.symmetryFold,
                        in: &context,
                        size: size
                    )
                }
            }
            .frame(width: 2048, height: 2048)
        )

        renderer.scale = 2.0

        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        }
    }
}
