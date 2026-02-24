import SwiftUI
import Combine

/// Screen 3 — Canvas Screen (Core Experience)
/// The main interactive screen where claps/taps create a Rangoli mandala.
struct CanvasScreen: View {
    let night: Night
    let isPassiveMode: Bool
    let onReflect: (SessionData) -> Void

    @EnvironmentObject var rhythmEngine: RhythmEngine
    @StateObject private var drawingEngine = PolarDrawingEngine()
    @StateObject private var bpmTracker = BPMTracker()
    @StateObject private var passiveSequencer = PassiveSequencer()

    @State private var symmetryFold: Int
    @State private var sessionStartTime: Date = .now
    @State private var latticeOpacity: Double = 0
    @State private var showTapHint: Bool = true
    @State private var waveformAmplitude: Float = 0
    @State private var cancellables = Set<AnyCancellable>()

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private let symmetryOptions = [4, 6, 8, 12]

    init(night: Night, isPassiveMode: Bool, onReflect: @escaping (SessionData) -> Void) {
        self.night = night
        self.isPassiveMode = isPassiveMode
        self.onReflect = onReflect
        self._symmetryFold = State(initialValue: night.defaultSymmetryFold)
    }

    var body: some View {
        ZStack {
            // Background
            Color(red: 0.03, green: 0.02, blue: 0.01)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Zone C — Floating Toolbar (top)
                floatingToolbar
                    .padding(.top, 16)
                    .padding(.horizontal, 16)

                // Zone A — Canvas (top 68%)
                canvasView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay {
                        // Tap gesture for fallback input
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handleTap()
                            }
                    }
                    .overlay(alignment: .center) {
                        if showTapHint {
                            Text("Tap or clap to draw")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                                .transition(.opacity)
                        }
                    }

                // Zone B — Rhythm Bar (bottom 22%)
                rhythmBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            setupSession()
        }
        .onDisappear {
            passiveSequencer.stop()
        }
    }

    // MARK: - Zone C: Floating Toolbar

    private var floatingToolbar: some View {
        GlassCard(cornerRadius: 22) {
            HStack(spacing: 16) {
                // Night indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(night.primaryColor)
                        .frame(width: 10, height: 10)
                    Text("Night \(night.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Night \(night.rawValue), \(night.goddessName)")

                Spacer()

                // Clear button
                Button {
                    drawingEngine.clearStrokes()
                    sessionStartTime = .now
                    bpmTracker.reset()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Clear canvas")

                // Save button
                Button {
                    saveCanvasSnapshot()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Save to Photos")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: 400)
    }

    // MARK: - Zone A: Canvas

    private var canvasView: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Update engine
                drawingEngine.update(date: timeline.date, canvasSize: size)

                // Draw dot lattice
                let lattice = RangoliLattice(night: night)
                SymmetryRenderer.drawLattice(
                    dots: lattice.dotPositions,
                    night: night,
                    in: &context,
                    size: size,
                    opacity: latticeOpacity * 0.3
                )

                // Draw all strokes with symmetry
                SymmetryRenderer.draw(
                    strokes: drawingEngine.strokes,
                    symmetryFold: symmetryFold,
                    in: &context,
                    size: size
                )
            }
        }
        .accessibilityLabel("Rangoli canvas with \(drawingEngine.beatCount) strokes, \(symmetryFold)-fold symmetry")
    }

    // MARK: - Zone B: Rhythm Bar

    private var rhythmBar: some View {
        GlassCard(cornerRadius: 20) {
            HStack(spacing: 20) {
                // Waveform visualization
                waveformView
                    .frame(width: 120, height: 40)
                    .accessibilityHidden(true)

                Spacer()

                // BPM readout
                VStack(spacing: 2) {
                    Text(bpmTracker.isTracking ? "\(Int(bpmTracker.currentBPM))" : "—")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .monospacedDigit()
                    Text("BPM")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(bpmTracker.isTracking ? "\(Int(bpmTracker.currentBPM)) beats per minute" : "No rhythm detected")

                Spacer()

                // Symmetry toggle
                VStack(spacing: 4) {
                    Text("Symmetry")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    HStack(spacing: 6) {
                        ForEach(symmetryOptions, id: \.self) { fold in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    symmetryFold = fold
                                    drawingEngine.setSymmetry(fold)
                                }
                            } label: {
                                Text("\(fold)")
                                    .font(.caption)
                                    .fontWeight(symmetryFold == fold ? .bold : .regular)
                                    .foregroundStyle(symmetryFold == fold ? .white : .white.opacity(0.4))
                                    .frame(width: 32, height: 32)
                                    .background(
                                        symmetryFold == fold
                                            ? night.primaryColor.opacity(0.4)
                                            : .white.opacity(0.05),
                                        in: RoundedRectangle(cornerRadius: 8)
                                    )
                            }
                            .accessibilityLabel("\(fold)-fold symmetry")
                            .accessibilityAddTraits(symmetryFold == fold ? .isSelected : [])
                        }
                    }
                }

                // Reflect button
                Button {
                    reflectSession()
                } label: {
                    Text("Reflect")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Color(red: 1.0, green: 0.55, blue: 0.0),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                }
                .accessibilityLabel("Reflect on your creation")
                .accessibilityHint("Freezes the mandala and generates a poem")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Waveform

    private var waveformView: some View {
        Canvas { context, size in
            let bars = 20
            let barWidth = size.width / CGFloat(bars) * 0.7
            let gap = size.width / CGFloat(bars) * 0.3

            for i in 0..<bars {
                let x = CGFloat(i) * (barWidth + gap)
                // Simulate waveform with noise + current amplitude
                let amplitude = CGFloat(waveformAmplitude) * CGFloat.random(in: 0.3...1.0)
                let barHeight = max(2, amplitude * size.height)
                let y = (size.height - barHeight) / 2

                let rect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
                context.fill(
                    Path(roundedRect: rect, cornerRadius: 1),
                    with: .color(night.primaryColor.opacity(0.6))
                )
            }
        }
        .onChange(of: rhythmEngine.currentAmplitude) { _, newValue in
            waveformAmplitude = newValue
        }
    }

    // MARK: - Actions

    private func setupSession() {
        sessionStartTime = .now

        // Configure drawing engine
        if isPassiveMode {
            drawingEngine.configure(night: night, beatPublisher: passiveSequencer.beatPublisher)
            passiveSequencer.start(night: night)
        } else {
            drawingEngine.configure(night: night, beatPublisher: rhythmEngine.beatPublisher)
        }

        // Subscribe beat events to BPM tracker
        let publisher = isPassiveMode ? passiveSequencer.beatPublisher : rhythmEngine.beatPublisher
        publisher
            .receive(on: RunLoop.main)
            .sink { [bpmTracker] event in
                Task { @MainActor in
                    bpmTracker.recordBeat(event)
                }
            }
            .store(in: &cancellables)

        // Update drawing engine BPM
        bpmTracker.$currentBPM
            .sink { [drawingEngine] bpm in
                Task { @MainActor in
                    drawingEngine.setBPM(bpm)
                }
            }
            .store(in: &cancellables)

        // Fade in lattice dots
        if reduceMotion {
            latticeOpacity = 1
        } else {
            withAnimation(.easeIn(duration: 0.8)) {
                latticeOpacity = 1
            }
        }

        // Hide tap hint after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation(.easeOut(duration: 0.5)) {
                showTapHint = false
            }
        }
    }

    private func handleTap() {
        rhythmEngine.fireTapBeat()

        if isPassiveMode {
            // In passive mode, tap adds beats on top of the sequence
            let event = BeatEvent.tapEvent()
            passiveSequencer.beatPublisher.send(event)
        }
    }

    private func reflectSession() {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let sessionData = SessionData(
            night: night,
            totalBeats: drawingEngine.beatCount,
            durationSeconds: duration,
            averageBPM: bpmTracker.currentBPM,
            peakAmplitude: rhythmEngine.currentAmplitude,
            symmetryFold: symmetryFold
        )
        passiveSequencer.stop()
        onReflect(sessionData)
    }

    private func saveCanvasSnapshot() {
        // Canvas snapshot is handled in ReflectionScreen for full export
    }
}
