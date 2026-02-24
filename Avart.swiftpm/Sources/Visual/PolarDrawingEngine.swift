import SwiftUI
import Combine

/// Core drawing state machine. Subscribes to beat events and maintains the array
/// of PolarStrokes that the Canvas renders each frame.
@MainActor
final class PolarDrawingEngine: ObservableObject {
    @Published var strokes: [PolarStroke] = []
    @Published var beatCount: Int = 0
    @Published var currentAngle: Double = 0
    @Published var symmetryFold: Int = 6
    @Published var isInLatticePhase: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var night: Night = .night3
    private var lattice: RangoliLattice?
    private var rotationVelocity: Double = 0  // radians per second
    private var lastFrameTime: Date = .now

    private let burstPhaseThreshold = 30  // First 30 beats = burst phase

    // MARK: - Setup

    /// Configure for a specific night and begin listening for beats
    func configure(night: Night, beatPublisher: PassthroughSubject<BeatEvent, Never>) {
        self.night = night
        self.symmetryFold = night.defaultSymmetryFold

        // Build the lattice for this night
        lattice = RangoliLattice(night: night)

        // Subscribe to beat events
        beatPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] event in
                self?.handleBeat(event)
            }
            .store(in: &cancellables)
    }

    /// Update called every frame from TimelineView (~60fps)
    func update(date: Date, canvasSize: CGSize) {
        let dt = date.timeIntervalSince(lastFrameTime)
        lastFrameTime = date

        // Rotate current angle based on BPM
        currentAngle += rotationVelocity * dt
        if currentAngle > 2 * .pi {
            currentAngle -= 2 * .pi
        }

        // Decay all strokes
        for i in strokes.indices {
            strokes[i].decay()
        }

        // Remove fully faded strokes (opacity < 0.01)
        strokes.removeAll { $0.opacity < 0.01 }
    }

    /// Set BPM to control rotation velocity: ω = BPM × (2π / 60)
    func setBPM(_ bpm: Double) {
        rotationVelocity = bpm * (2 * .pi / 60.0)
    }

    /// Change symmetry fold. Does NOT clear existing strokes.
    func setSymmetry(_ fold: Int) {
        symmetryFold = fold
    }

    /// Clear all strokes
    func clearStrokes() {
        strokes.removeAll()
        beatCount = 0
        isInLatticePhase = false
        lattice?.reset()
    }

    /// Take a snapshot of current state for reflection
    func snapshot() -> [PolarStroke] {
        return strokes
    }

    // MARK: - Beat Handling

    private func handleBeat(_ event: BeatEvent) {
        beatCount += 1

        // Fire haptic
        HapticController.shared.fireBeatHaptic(amplitude: event.amplitude)

        // Select a color from the night palette
        let colorIndex = beatCount % night.strokeColors.count
        let color = night.strokeColors[colorIndex]

        if beatCount <= burstPhaseThreshold {
            // BURST PHASE: radial lines outward from center
            addBurstStroke(event: event, color: color)
        } else {
            // LATTICE PHASE: Eulerian lattice connections
            isInLatticePhase = true
            if let latticeStroke = addLatticeStroke(event: event, color: color) {
                strokes.append(latticeStroke)
            } else {
                // Fallback to burst if lattice is exhausted
                addBurstStroke(event: event, color: color)
            }
        }

        // Bloom effect for high-amplitude beats
        if event.isBloom {
            addBloomEffect(event: event, color: color)
        }
    }

    private func addBurstStroke(event: BeatEvent, color: Color) {
        let stroke = PolarStroke.burstStroke(
            angle: currentAngle + Double.random(in: -0.3...0.3),
            amplitude: event.amplitude,
            rms: event.rms,
            color: color
        )
        strokes.append(stroke)
    }

    private func addLatticeStroke(event: BeatEvent, color: Color) -> PolarStroke? {
        guard let edge = lattice?.nextEdge() else { return nil }

        return PolarStroke.latticeStroke(
            fromAngle: edge.fromAngle,
            fromRadius: edge.fromRadius,
            toAngle: edge.toAngle,
            toRadius: edge.toRadius,
            amplitude: event.amplitude,
            rms: event.rms,
            color: color
        )
    }

    /// Extra-thick stroke spike for high amplitude (bloom effect)
    private func addBloomEffect(event: BeatEvent, color: Color) {
        for i in 0..<symmetryFold {
            let angle = currentAngle + (2 * .pi / Double(symmetryFold)) * Double(i)
            var stroke = PolarStroke.burstStroke(
                angle: angle,
                amplitude: min(event.amplitude * 1.3, 1.0),
                rms: event.rms,
                color: color
            )
            stroke.weight *= 2.0  // Extra thick for bloom
            stroke.endRadius *= 1.4
            strokes.append(stroke)
        }
    }
}
