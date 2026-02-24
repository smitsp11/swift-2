import Foundation
import Combine

/// Generates pre-programmed BeatEvents for the "Start the Cycle" passive mode.
/// Simulates Titodo rhythm for the selected night, accelerating from 90 → 120 BPM.
@MainActor
final class PassiveSequencer: ObservableObject {
    @Published var isPlaying: Bool = false

    let beatPublisher = PassthroughSubject<BeatEvent, Never>()

    private var timer: Timer?
    private var beatIndex: Int = 0
    private var startTime: Date = .now
    private let totalDuration: TimeInterval = 90 // 90 seconds of playback

    // Titodo rhythm pattern: three beats per cycle
    // Night 3: beats at 0ms, 667ms, 1333ms within each cycle (~90 BPM)
    private let titodoPattern: [TimeInterval] = [0, 0.667, 1.333]
    private var currentPatternIndex: Int = 0

    /// Start the passive sequencer for a given night
    func start(night: Night) {
        stop()

        isPlaying = true
        startTime = .now
        beatIndex = 0
        currentPatternIndex = 0

        scheduleNextBeat(night: night)
    }

    /// Stop the sequencer
    func stop() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        beatIndex = 0
        currentPatternIndex = 0
    }

    private func scheduleNextBeat(night: Night) {
        let elapsed = Date().timeIntervalSince(startTime)
        guard elapsed < totalDuration else {
            stop()
            return
        }

        // Calculate current BPM: accelerate from 90 → 120 over 60 seconds
        let progress = min(elapsed / 60.0, 1.0)
        let currentBPM = 90.0 + (30.0 * progress)
        let beatInterval = 60.0 / currentBPM

        // Titodo pattern: cycle through three beats
        let patternOffset = titodoPattern[currentPatternIndex] * (beatInterval / 0.667)

        // Vary amplitude slightly for natural feel
        let amplitudeVariation = Float.random(in: 0.55...0.85)
        let rmsVariation = Float.random(in: 0.4...0.7)

        let event = BeatEvent(
            timestamp: Date(),
            amplitude: amplitudeVariation,
            rms: rmsVariation
        )

        beatPublisher.send(event)
        beatIndex += 1
        currentPatternIndex = (currentPatternIndex + 1) % titodoPattern.count

        // Schedule next beat
        let nextDelay: TimeInterval
        if currentPatternIndex == 0 {
            // End of pattern cycle — full beat interval minus pattern offsets
            nextDelay = beatInterval * 0.5
        } else {
            nextDelay = beatInterval * titodoPattern[currentPatternIndex] / 2.0
        }

        timer = Timer.scheduledTimer(withTimeInterval: max(nextDelay, 0.1), repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.scheduleNextBeat(night: night)
            }
        }
    }
}
