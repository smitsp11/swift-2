import Foundation
import FoundationModels

/// On-device poem generation using Foundation Models.
/// Falls back to curated poems if the model is unavailable.
@MainActor
final class ReflectionGenerator {

    @Generable
    struct NightReflection {
        @Guide(description: "A single evocative word in Sanskrit or Gujarati that captures the session")
        var word: String
        @Guide(description: "A 3-line reflective poem, each line under 12 words, inspired by Navratri")
        var poem: String
    }

    /// Generate a reflection from session data.
    /// Uses Foundation Models on-device; falls back to curated strings if unavailable.
    func generate(from sessionData: SessionData) async -> NightReflection {
        // Try Foundation Models first
        do {
            let session = LanguageModelSession()
            let prompt = sessionData.buildPrompt()
            let response = try await session.respond(to: prompt, generating: NightReflection.self)
            return response
        } catch {
            print("FoundationModels unavailable, using fallback: \(error)")
            return fallbackReflection(for: sessionData)
        }
    }

    // MARK: - Fallback Poems (9 total: 3 per night)

    private func fallbackReflection(for session: SessionData) -> NightReflection {
        let poems = fallbackPoems[session.night] ?? fallbackPoems[.night3]!
        let hash = abs(session.totalBeats + Int(session.peakAmplitude * 100))
        let index = hash % poems.count
        return poems[index]
    }

    private let fallbackPoems: [Night: [NightReflection]] = [
        .night1: [
            NightReflection(
                word: "Aarambh",
                poem: """
                From silence, the first beat rises like dawn.
                Hands find the rhythm earth already knows.
                Every beginning holds the whole circle within.
                """
            ),
            NightReflection(
                word: "Prakriti",
                poem: """
                The mountain's daughter dances in your pulse.
                Nature answers back in lines of gold.
                What the hands create, the heart remembers.
                """
            ),
            NightReflection(
                word: "Shakti",
                poem: """
                Strength is not volume but persistence.
                Each clap a seed planted in geometry.
                The mandala grows where intention falls.
                """
            )
        ],
        .night3: [
            NightReflection(
                word: "Sahas",
                poem: """
                Bravery is the space between two beats.
                The bell resonates where fear once lived.
                Chandraghanta's crescent cuts through doubt.
                """
            ),
            NightReflection(
                word: "Dhairya",
                poem: """
                Courage draws in lines the eye can follow.
                Symmetry emerges from the chaos of intention.
                Your rhythm told a story of steady hands.
                """
            ),
            NightReflection(
                word: "Tej",
                poem: """
                Like light through a prism, rhythm splits into color.
                The third night burns with focused brilliance.
                What you drew tonight carries the warmth of bravery.
                """
            )
        ],
        .night8: [
            NightReflection(
                word: "Prakash",
                poem: """
                Radiance needs no audience to shine.
                The eighth night dissolves what was never real.
                In grace, the geometry finds its final form.
                """
            ),
            NightReflection(
                word: "Ananda",
                poem: """
                Joy is the mathematics the universe prefers.
                Eight mirrors reflect one truth, made beautiful.
                The mandala completes what words cannot.
                """
            ),
            NightReflection(
                word: "Mukti",
                poem: """
                Transcendence hides in the space between petals.
                What the hands release, the light receives.
                Mahagauri smiles in your final stroke.
                """
            )
        ]
    ]
}
