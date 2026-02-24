import CoreHaptics
import UIKit

/// Singleton haptic controller using CHHapticEngine.
/// Pre-compiles three patterns for sub-8ms fire latency.
@MainActor
final class HapticController {
    static let shared = HapticController()

    private var engine: CHHapticEngine?
    private var softPattern: CHHapticPattern?
    private var standardPattern: CHHapticPattern?
    private var bloomPattern: CHHapticPattern?

    private init() {}

    /// Prepare the haptic engine and pre-compile patterns.
    func prepare() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let engine = try CHHapticEngine()
            engine.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            engine.stoppedHandler = { _ in }
            try engine.start()
            self.engine = engine

            // Pre-compile patterns
            softPattern = try createPattern(intensity: 0.3, sharpness: 0.2, duration: 0.05)
            standardPattern = try createPattern(intensity: 0.6, sharpness: 0.5, duration: 0.08)
            bloomPattern = try createBloomPattern()
        } catch {
            print("Haptic engine setup failed: \(error)")
        }
    }

    /// Fire haptic for a beat event
    func fireBeatHaptic(amplitude: Float) {
        guard let engine = engine else { return }

        do {
            let pattern: CHHapticPattern?
            if amplitude > 0.75 {
                pattern = bloomPattern
            } else if amplitude > 0.4 {
                pattern = standardPattern
            } else {
                pattern = softPattern
            }

            guard let p = pattern else { return }
            let player = try engine.makePlayer(with: p)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            // Silently fail — haptics are enhancement, not required
        }
    }

    private func createPattern(intensity: Float, sharpness: Float, duration: TimeInterval) throws -> CHHapticPattern {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0,
            duration: duration
        )
        return try CHHapticPattern(events: [event], parameters: [])
    }

    private func createBloomPattern() throws -> CHHapticPattern {
        // Bloom: two-stage haptic — sharp transient followed by a sustained rumble
        let transient = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0,
            duration: 0.05
        )
        let sustained = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0.05,
            duration: 0.15
        )
        return try CHHapticPattern(events: [transient, sustained], parameters: [])
    }
}
