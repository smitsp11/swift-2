import Foundation

/// Captures the complete session data used to generate a reflection poem.
struct SessionData {
    let night: Night
    let totalBeats: Int
    let durationSeconds: TimeInterval
    let averageBPM: Double
    let peakAmplitude: Float
    let symmetryFold: Int

    /// Build a prompt string for Foundation Models
    func buildPrompt() -> String {
        let durationFormatted = String(format: "%.0f", durationSeconds)
        let bpmFormatted = String(format: "%.0f", averageBPM)
        let ampFormatted = String(format: "%.2f", peakAmplitude)

        return """
        The user completed Night \(night.rawValue) of Navratri (\(night.goddessName), \
        the goddess representing \(night.culturalAttributes)). \
        Their session: \(totalBeats) beats over \(durationFormatted) seconds, \
        average BPM \(bpmFormatted), peak amplitude \(ampFormatted), \
        symmetry \(symmetryFold)-fold, primary geometry \(night.primaryGeometry). \
        Write a 3-line reflective poem inspired by these qualities and the attributes of \(night.goddessName). \
        Also provide a single evocative Sanskrit or Gujarati word that captures the session's essence. \
        Return only JSON with fields "word" and "poem".
        """
    }
}
