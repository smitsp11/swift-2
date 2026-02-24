import Foundation
import AVFoundation
import Accelerate
import Combine

/// Central audio controller. Owns the AVAudioEngine, manages microphone input,
/// ambient calibration, and publishes detected beats.
@MainActor
final class RhythmEngine: ObservableObject {
    enum InputMode {
        case microphone
        case tapOnly
    }

    @Published var inputMode: InputMode = .microphone
    @Published var isRunning: Bool = false
    @Published var currentAmplitude: Float = 0
    @Published var micPermissionDenied: Bool = false

    let beatPublisher = PassthroughSubject<BeatEvent, Never>()

    private var audioEngine: AVAudioEngine?
    private var beatDetector: BeatDetector?
    private var ambientFloor: Float = 0.01
    private var calibrationBuffers: [Float] = []
    private let calibrationBufferCount = 200  // ~4.6 seconds at 44.1kHz / 1024
    private var isCalibrating = false

    // MARK: - Lifecycle

    /// Request microphone permission and configure audio.
    func requestPermissionAndSetup() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self = self else { return }
                if granted {
                    self.inputMode = .microphone
                    self.setupAudioEngine()
                } else {
                    self.inputMode = .tapOnly
                    self.micPermissionDenied = true
                }
            }
        }
    }

    /// Start the audio engine (after calibration)
    func start() {
        guard inputMode == .microphone else {
            isRunning = true
            return
        }
        setupAudioEngine()
    }

    /// Stop the audio engine
    func stop() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        isRunning = false
    }

    /// Generate a beat event from a screen tap (fallback input)
    func fireTapBeat() {
        let event = BeatEvent.tapEvent()
        beatPublisher.send(event)
    }

    // MARK: - Audio Setup

    private func setupAudioEngine() {
        let engine = AVAudioEngine()
        self.audioEngine = engine

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("AVAudioSession setup failed: \(error)")
            inputMode = .tapOnly
            isRunning = true
            return
        }

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Start with calibration phase
        isCalibrating = true
        calibrationBuffers.removeAll()

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            Task { @MainActor in
                self?.handleAudioBuffer(buffer)
            }
        }

        do {
            try engine.start()
            isRunning = true
        } catch {
            print("AVAudioEngine start failed: \(error)")
            inputMode = .tapOnly
            isRunning = true
        }
    }

    private func handleAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = vDSP_Length(buffer.frameLength)

        // Update current amplitude for waveform visualization
        var peak: Float = 0
        vDSP_maxv(channelData, 1, &peak, frameCount)
        currentAmplitude = peak

        if isCalibrating {
            // Calibration phase: collect ambient floor samples
            var rms: Float = 0
            vDSP_rmsqv(channelData, 1, &rms, frameCount)
            calibrationBuffers.append(rms)

            if calibrationBuffers.count >= calibrationBufferCount {
                finishCalibration()
            }
        } else if let detector = beatDetector {
            // Detection phase: check for beats
            if let event = detector.processPCMBuffer(buffer) {
                beatPublisher.send(event)
            }
        }
    }

    private func finishCalibration() {
        isCalibrating = false

        // Compute mean RMS as ambient floor
        guard !calibrationBuffers.isEmpty else {
            ambientFloor = 0.01
            beatDetector = BeatDetector(ambientFloor: ambientFloor)
            return
        }

        var mean: Float = 0
        vDSP_meanv(calibrationBuffers, 1, &mean, vDSP_Length(calibrationBuffers.count))
        ambientFloor = max(mean, 0.001)
        calibrationBuffers.removeAll()

        beatDetector = BeatDetector(ambientFloor: ambientFloor)
        print("Ambient calibration complete. Floor: \(ambientFloor)")
    }
}
