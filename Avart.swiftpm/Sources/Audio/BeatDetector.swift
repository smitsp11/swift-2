import Foundation
import AVFoundation
import Accelerate
import Combine

/// Detects beats from PCM audio buffers using vDSP peak detection.
/// Runs on the audio thread — `processPCMBuffer` must complete in <5ms.
final class BeatDetector: Sendable {
    private let ambientFloor: Float
    private let debounceInterval: TimeInterval = 0.10  // 100ms debounce

    // Mutable state accessed from audio thread
    private let lastBeatTime = MutableState<Date>(.distantPast)

    init(ambientFloor: Float) {
        self.ambientFloor = max(ambientFloor, 0.001) // Prevent zero threshold
    }

    /// Process a PCM buffer and return a BeatEvent if a beat is detected.
    /// Called on the audio render thread — must be fast.
    func processPCMBuffer(_ buffer: AVAudioPCMBuffer) -> BeatEvent? {
        guard let channelData = buffer.floatChannelData?[0] else { return nil }
        let frameCount = vDSP_Length(buffer.frameLength)

        // Peak detection
        var peak: Float = 0
        vDSP_maxv(channelData, 1, &peak, frameCount)

        // Threshold: ambient floor × 4.0 ≈ +12dB above ambient
        guard peak > ambientFloor * 4.0 else { return nil }

        // Debounce: 100ms minimum between beats to prevent echo double-fire
        let now = Date()
        guard now.timeIntervalSince(lastBeatTime.value) > debounceInterval else { return nil }
        lastBeatTime.value = now

        // Compute RMS energy
        let rms = computeRMS(channelData, frameCount)

        return BeatEvent(
            timestamp: now,
            amplitude: min(peak, 1.0),
            rms: rms
        )
    }

    /// Get current amplitude for waveform visualization (no beat detection logic)
    func currentAmplitude(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameCount = vDSP_Length(buffer.frameLength)
        var peak: Float = 0
        vDSP_maxv(channelData, 1, &peak, frameCount)
        return peak
    }

    private func computeRMS(_ data: UnsafePointer<Float>, _ count: vDSP_Length) -> Float {
        var rms: Float = 0
        vDSP_rmsqv(data, 1, &rms, count)
        return min(rms, 1.0)
    }
}

/// Thread-safe mutable wrapper for audio thread access
private final class MutableState<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T

    init(_ value: T) {
        _value = value
    }

    var value: T {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}
