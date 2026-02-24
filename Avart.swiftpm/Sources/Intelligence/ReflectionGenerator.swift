import Foundation

/// On-device poem generation.
/// Uses hardcoded curated poems since FoundationModels requires iOS 26+.
/// When iOS 26 SDK becomes available, uncomment the FoundationModels integration below.
@MainActor
final class ReflectionGenerator {

    struct NightReflection {
        var word: String
        var poem: String
    }

    /// Generate a reflection from session data.
    /// Currently uses curated fallback poems.
    /// When FoundationModels is available (iOS 26+), this will use on-device AI generation.
    func generate(from sessionData: SessionData) async -> NightReflection {
        // TODO: When iOS 26 SDK is available, uncomment:
        // import FoundationModels
        // @Generable struct ... { }
        // let session = LanguageModelSession()
        // return try await session.respond(to: prompt, generating: NightReflection.self)

        return fallbackReflection(for: sessionData)
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
