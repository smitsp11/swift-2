import Foundation

/// A single detected rhythmic event — either from a microphone clap or a screen tap.
struct BeatEvent: Identifiable, Sendable {
    let id = UUID()
    let timestamp: Date
    let amplitude: Float   // Peak amplitude (0.0–1.0)
    let rms: Float         // RMS energy of the buffer

    /// Standard tap-generated event with medium amplitude
    static func tapEvent() -> BeatEvent {
        BeatEvent(
            timestamp: Date(),
            amplitude: 0.7,
            rms: 0.5
        )
    }

    /// Whether this beat qualifies as a "bloom" (high amplitude)
    var isBloom: Bool {
        amplitude > 0.75
    }
}
