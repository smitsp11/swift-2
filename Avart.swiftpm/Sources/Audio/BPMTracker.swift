import Foundation
import Combine

/// Tracks BPM from a stream of BeatEvents using rolling median of inter-beat intervals.
/// Median is robust to irregular claps (unlike mean).
@MainActor
final class BPMTracker: ObservableObject {
    @Published var currentBPM: Double = 0
    @Published var isTracking: Bool = false

    private var timestamps: [Date] = []
    private let maxTimestamps = 16
    private var beatsSinceLastUpdate = 0
    private let updateInterval = 4  // Update BPM every 4 beats

    /// Record a new beat and update BPM if enough data.
    func recordBeat(_ event: BeatEvent) {
        timestamps.append(event.timestamp)

        // Keep only the last N timestamps
        if timestamps.count > maxTimestamps {
            timestamps.removeFirst(timestamps.count - maxTimestamps)
        }

        beatsSinceLastUpdate += 1

        // Need at least 2 timestamps and update every 4 beats
        guard timestamps.count >= 2,
              beatsSinceLastUpdate >= updateInterval else { return }

        beatsSinceLastUpdate = 0
        updateBPM()
    }

    /// Reset tracking state
    func reset() {
        timestamps.removeAll()
        currentBPM = 0
        isTracking = false
        beatsSinceLastUpdate = 0
    }

    private func updateBPM() {
        // Compute all inter-beat intervals
        let ibis = zip(timestamps, timestamps.dropFirst()).map { pair in
            pair.1.timeIntervalSince(pair.0)
        }

        guard !ibis.isEmpty else { return }

        // Take median (robust to outliers)
        let sorted = ibis.sorted()
        let medianIBI = sorted[sorted.count / 2]

        guard medianIBI > 0 else { return }

        let bpm = 60.0 / medianIBI

        // Sanity check: BPM should be in reasonable range (30–300)
        if bpm >= 30 && bpm <= 300 {
            currentBPM = bpm
            isTracking = true
        }
    }
}
