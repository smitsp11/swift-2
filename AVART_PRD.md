
AVART
The Rhythmic Geometry of Navratri
Product Requirements Document  ·  Swift Student Challenge 2026

For the Software Engineer






# 0. Scope Calibration: The Otto Benchmark
Before writing a single line of code, the engineer must internalize the scope of a winning submission. The reference point is Otto — a Swift Student Challenge winner built as a personal audiologist for hearing loss. Understanding its architecture prevents the most common failure mode in student submissions: building too much.

## 0.1 What Otto Did (And What It Didn't)
Otto had exactly three screens and three features. Nothing more.



## 0.2 Scope Mapping: Avart vs. Otto



# 1. Product Overview
## 1.1 App Identity

## 1.2 The Golden Path (3-Minute Judge Experience)
This is the only user journey that matters for the submission. Every engineering decision must protect this path. If a feature does not appear in this path, it is a stretch goal — not a requirement.





# 2. Screens & UX Specification
Avart has exactly four screens. No more are permitted in the submission build. Every screen maps directly to a step in the Golden Path.

## Screen 1 — Launch Screen

Layout
Background: Full-screen dark canvas. Near-black (#0D0500). No images.
Central Diya: A single glowing amber circle drawn with SwiftUI Canvas using a radial gradient (amber core → transparent edge). Pulses using a sinusoidal opacity animation at 0.8Hz. This is drawn in code, not a PNG.
Ambient Reactivity: AVAudioEngine inputNode monitors ambient sound level continuously. Any transient above ambient floor + 8dB causes the diya's glow radius to spike by 20% and return over 300ms. This makes the app feel alive before the judge taps anything.
Title: 'AVART' in SF Pro Display, bold, white, 48pt. Positioned 80pt above the diya. Uses .ultraThinMaterial background behind the text to achieve the Liquid Glass frosted effect.
Subtitle: 'The Rhythmic Geometry of Navratri' in SF Pro, regular, 16pt, gold (#B8860B). Below the title.
Buttons: Two CTA buttons in glass-effect cards. 'Start the Cycle' (secondary, left) and 'Enter the Circle' (primary, right). Both use glassEffect() modifier. Primary button has amber stroke (#FF8C00, 1px).

Behavior Notes
Passive mode (Start the Cycle): Bypasses Night Selection. Launches directly into Canvas in passive mode with Night 3 pre-selected. A pre-programmed Titodo rhythm auto-plays and draws the mandala without user input. This is the 'screensaver' mode for judges who want to observe before participating.
Active mode (Enter the Circle): Proceeds to Night Selection. This is the primary Golden Path.
Microphone permission: Requested immediately on first launch of active mode, BEFORE the Night Selection screen. Uses standard AVAudioSession authorization flow. If denied, app falls back gracefully to tap-only mode and shows a one-line notice: 'Tap the canvas to draw your rhythm.'

## Screen 2 — Night Selection Screen

The Three Nights (Launch Build)

Card Component Spec
Dimensions: Card width: 260pt. Height: 360pt. Corner radius: 24pt, concentric with iPad screen corners.
Material: glassEffect() modifier applied to card container. Background bleeds through from the parent gradient.
Content: Goddess name in Gujarati script (top), English name below, color swatch strip (16pt tall, full card width), Night number in large ambient text (120pt, 5% opacity, bottom-right corner).
Interaction: Tap → immediate background gradient transition to that night's palette (0.6s withAnimation(.easeInOut)). Card scales up to 1.05 for 150ms then returns. 3-second synthesized rhythm preview plays via AVAudioEngine (synthesized clicks, no audio files).
Scroll behavior: Horizontal ScrollView with .scrollTargetBehavior(.viewAligned). Snaps to each card. Initial position shows Night 1 centered. Night 3 is visible at right edge as a scroll affordance.

## Screen 3 — Canvas Screen (Core Experience)

Layout Zones
Zone A — Canvas (top 68% of screen): Full-width dark canvas. Contains the live Rangoli drawing rendered by SwiftUI Canvas + TimelineView at 60fps. No UI chrome overlaps this zone.
Zone B — Rhythm Bar (bottom 22% of screen): A floating glass panel. Contains: live waveform visualization of microphone input, current BPM readout (large, centered), symmetry toggle (4 / 6 / 8 / 12-fold), and the 'Reflect' button (right side, amber).
Zone C — Floating Toolbar (top of screen, overlaid): A minimal glass pill: Night indicator (colored dot + name), Clear button, Save button. 44pt tap targets. Positioned 16pt from top safe area.

Canvas Behavior
On entry: Dot lattice fades in over 800ms. For Night 3: 9x9 grid of soft blue dots, arranged radially. For Night 1: 5x5 square grid. For Night 8: 13x13 radial grid.
First 30 beats (Burst Phase): BeatEvents trigger radial lines outward from center. Every line is mirrored across all N symmetry axes immediately. This guarantees visual impact within the first 5 seconds. No Eulerian logic in this phase.
After 30 beats (Lattice Phase): Drawing engine transitions from radial lines to Eulerian lattice connections between dot grid nodes. The radial lines remain; new strokes begin connecting dots in paths. The drawing becomes denser and more intricate.
Stroke properties: Amplitude peak → stroke weight (1pt to 8pt linear). RMS energy → stroke opacity (0.4 to 1.0). Night color palette determines hue. All strokes use Path.addCurve for fluid Bezier arcs.
Decay: Each stroke alpha multiplies by 0.9992 per frame (~60fps). Strokes fade naturally over ~80 seconds if no new beats arrive. The canvas clears itself gracefully without user action.
Symmetry toggle: Changing symmetry mid-session does NOT clear existing strokes. It re-mirrors all existing PolarStroke objects into the new symmetry group and continues drawing in the new configuration. This is the 'magic moment' — the judge sees their work double in complexity instantly.

Input Handling
Primary input — Microphone: AVAudioEngine inputNode bus tap. 1024-sample buffer at 44.1kHz. vDSP_maxv amplitude peak detection. Threshold = ambient floor + 15dB (calibrated on first launch). BeatEvent fires on threshold crossing with 100ms debounce to prevent double-fire on single clap echo.
Fallback input — Screen Tap: An invisible UITapGestureRecognizer covers the full canvas zone. Tap fires a BeatEvent with velocity = 0.7 (medium amplitude). This is labeled 'Tap to Draw' in a 12pt hint that fades after 5 seconds.
BPM detection: Stores last 16 BeatEvent timestamps. Median inter-beat interval → BPM. Updates every 4 beats. Displayed in Rhythm Bar. Controls visual engine rotation velocity: ω = BPM × (2π / 60).

Passive Mode Differences
When entered via 'Start the Cycle,' the Canvas runs identically except BeatEvents are generated by a pre-programmed timer sequence rather than microphone input. The sequence for Night 3 Titodo: beats at 0ms, 667ms, 1333ms, repeating at ~90 BPM for 90 seconds, then accelerating to 120 BPM. The judge can tap the canvas at any time to add their own beats on top of the sequence.

## Screen 4 — Reflection Screen

Layout
Top half: The completed Rangoli mandala, frozen at the moment 'Reflect' was tapped. Rendered as a static Canvas snapshot. Faint glow continues pulsing (opacity only, no geometry changes).
Bottom half: Glass card containing: a single evocative word in large gold type (e.g., 'Sahas' — Bravery), the 3-line generated poem in white, 16pt, and two action buttons: 'Save to Photos' and 'New Night.'
Loading state: While Foundation Models generates the poem (typically 1–3 seconds on device), a subtle shimmer animation plays on the poem area. No spinner. The mandala glow pulses during this wait.

Foundation Models Integration
Framework: FoundationModels. Requires iOS 26 / macOS 26. Run on-device. No network.
Output type: @Generable struct with two fields: word: String and poem: String.
Prompt construction: Built from SessionData struct. Example: 'The user completed Night 3 of Navratri (Chandraghanta, the goddess of bravery and focus). Their session: 47 beats over 72 seconds, average BPM 94, peak amplitude 0.82, symmetry 6-fold, primary geometry triangular. Write a 3-line reflective poem inspired by these qualities and the attributes of Chandraghanta. Also provide a single evocative Sanskrit or Gujarati word that captures the session. Return only JSON.'
Offline guarantee: FoundationModels runs entirely on the Neural Engine. Zero URLSession. Tested in Airplane Mode. If model load fails (first launch on unsupported device), fallback to one of 9 curated poems per night (hardcoded strings).
Export: UIGraphicsImageRenderer captures the full screen (mandala + poem card). UIImageWriteToSavedPhotosAlbum writes to Photos. No network share. AirDrop and system share sheet available via UIActivityViewController.



# 3. Technical Architecture
Avart is built on the principle of Math as Asset. Every visual element is computed at runtime from mathematical functions. Every audio event is synthesized or analyzed locally. The Resources folder contains zero image or audio files.

## 3.1 Project Structure
Avart.swiftpm/
├── Sources/
│   ├── App/
│   │   ├── AvartApp.swift              // @main entry point
│   │   └── ContentView.swift            // Root navigation router
│   ├── Screens/
│   │   ├── LaunchScreen.swift
│   │   ├── NightSelectionScreen.swift
│   │   ├── CanvasScreen.swift
│   │   └── ReflectionScreen.swift
│   ├── Audio/
│   │   ├── RhythmEngine.swift           // AVAudioEngine wrapper
│   │   ├── BeatDetector.swift           // vDSP peak detection + debounce
│   │   ├── BPMTracker.swift             // Rolling median BPM
│   │   └── PassiveSequencer.swift       // Pre-programmed Titodo beats
│   ├── Visual/
│   │   ├── PolarDrawingEngine.swift     // Core drawing state machine
│   │   ├── RangoliLattice.swift         // Dot grid + Eulerian path logic
│   │   ├── PolarStroke.swift            // Stroke data model
│   │   └── SymmetryRenderer.swift       // Dihedral mirroring
│   ├── Haptics/
│   │   └── HapticController.swift       // CHHapticEngine patterns
│   ├── Intelligence/
│   │   ├── ReflectionGenerator.swift   // FoundationModels integration
│   │   └── SessionData.swift            // Input struct for poem prompt
│   └── Models/
│       ├── Night.swift                  // Night enum + metadata
│       └── BeatEvent.swift              // Timestamped beat data
└── Package.swift


## 3.2 Audio Engine — RhythmEngine.swift
The RhythmEngine is an ObservableObject that owns the AVAudioEngine instance for its entire lifecycle. It exposes a beatPublisher: PassthroughSubject<BeatEvent, Never> that the Canvas subscribes to.

Initialization Sequence
Configure AVAudioSession: .playAndRecord category, .defaultToSpeaker option.
Request microphone authorization. On denial, set inputMode = .tapOnly.
Ambient calibration: record 200 audio buffers (~4.6 seconds at 44.1kHz with 1024 buffer size). Use vDSP_meanv to compute ambient RMS. Store as ambientFloor.
Install inputNode bus tap: buffer size 1024, sample rate 44100.
Start AVAudioEngine.

Beat Detection (BeatDetector.swift)
Called every buffer callback (~23ms). Must complete in under 5ms to avoid audio thread starvation.
func processPCMBuffer(_ buffer: AVAudioPCMBuffer) {
    guard let channelData = buffer.floatChannelData?[0] else { return }
    let frameCount = vDSP_Length(buffer.frameLength)
    var peak: Float = 0
    vDSP_maxv(channelData, 1, &peak, frameCount)
    guard peak > ambientFloor * 4.0 else { return }  // +~12dB threshold
    guard Date().timeIntervalSince(lastBeatTime) > 0.10 else { return } // 100ms debounce
    lastBeatTime = Date()
    let event = BeatEvent(timestamp: Date(), amplitude: peak, rms: computeRMS(channelData, frameCount))
    beatPublisher.send(event)
}

BPM Tracking (BPMTracker.swift)
Stores last 16 beat timestamps. Computes all inter-beat intervals. Takes the median (not mean — median is robust to irregular claps). Converts to BPM. Publishes update every 4 beats minimum.
// median IBI → BPM
let ibis = zip(timestamps, timestamps.dropFirst()).map { $1 - $0 }
let medianIBI = ibis.sorted()[ibis.count / 2]
let bpm = 60.0 / medianIBI

Passive Sequencer (PassiveSequencer.swift)
Used when judge taps 'Start the Cycle.' Generates BeatEvents on a timer matching the pre-programmed Titodo rhythm for the selected night. Timer fires on a background DispatchQueue, then publishes on main. The sequence accelerates from 90 BPM to 120 BPM over 60 seconds to simulate a real Garba performance.

## 3.3 Visual Engine — PolarDrawingEngine.swift
An ObservableObject that owns the drawing state. Subscribes to beatPublisher. Maintains an array of PolarStroke values. Published to the Canvas view which re-renders every TimelineView tick.

PolarStroke Model
struct PolarStroke: Identifiable {
    let id = UUID()
    var angle: Double        // Radians from center
    var radius: Double       // Distance from center (pts)
    var arcLength: Double    // Length of stroke (pts)
    var weight: CGFloat      // Stroke width (1–8pt)
    var color: Color         // Night palette color
    var opacity: Double      // Current alpha (decays each frame)
    var controlOffset: CGSize // Bezier control point offset
}

Beat → Stroke Mapping

Symmetry Rendering (SymmetryRenderer.swift)
For each PolarStroke, the renderer draws it N times rotated by (2π / N) around the canvas center, where N is the current symmetry fold (4, 6, 8, or 12). This is applied using context.concatenate(CGAffineTransform(rotationAngle: sliceAngle)) inside a for loop in the Canvas draw closure.
for i in 0..<symmetryFold {
    let angle = (2 * .pi / Double(symmetryFold)) * Double(i)
    context.concatenate(.init(rotationAngle: angle))
    context.stroke(path, with: .color(stroke.color.opacity(stroke.opacity)),
                   lineWidth: stroke.weight)
}

Eulerian Lattice Phase (RangoliLattice.swift)
Activated after 30 BeatEvents. The lattice is a graph where nodes are the Pulli dot positions and edges are possible straight-line connections between adjacent nodes. The Eulerian path algorithm (Hierholzer's algorithm) computes a traversal that visits each edge at most once. Each BeatEvent advances the traversal by one edge, drawing that edge as a PolarStroke.

## 3.4 Haptic Controller — HapticController.swift
A singleton that owns the CHHapticEngine. Pre-compiles three haptic patterns at launch to achieve sub-8ms fire latency.


## 3.5 Reflection Generator — ReflectionGenerator.swift
import FoundationModels

@Generable
struct NightReflection {
    @Guide(description: "A single evocative word in Sanskrit or Gujarati")
    let word: String
    @Guide(description: "A 3-line poem (each line under 12 words)")
    let poem: String
}

func generate(from session: SessionData) async throws -> NightReflection {
    let session = LanguageModelSession()
    let prompt = buildPrompt(session)
    return try await session.respond(to: prompt, generating: NightReflection.self)
}

The buildPrompt function constructs a string from SessionData: night number, goddess name, cultural attributes, average BPM, peak amplitude, total beats, session duration, and symmetry fold. This gives the model enough context to produce a reflection that feels uniquely tied to what the user actually played.

Fallback (Device Doesn't Support FoundationModels)
If LanguageModelSession() throws an unavailability error, ReflectionGenerator falls back to a pre-written array of NightReflection values — three per night (nine total hardcoded strings). The fallback is selected by: hash(totalBeats + peakAmplitude) % 3. The user cannot tell the difference in the time available.



# 4. Design Specification
## 4.1 Design Language: Liquid Glass on Dark
Avart's aesthetic is Liquid Glass applied over a deep cultural darkness — the visual world of a Navratri night. Every glass surface refracts the animated gradient beneath it. The result feels like looking at Rangoli through a clay lantern.

Color System

Glass Card Component
Used for Night selection cards, Rhythm Bar, and Reflection card. Implemented as a reusable GlassCard<Content: View> struct:
struct GlassCard<Content: View>: View {
    var body: some View {
        content
            .background(.ultraThinMaterial)
            .glassEffect(.regular.interactive())
            .overlay(RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.15), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

## 4.2 Typography

## 4.3 Animation Inventory



# 5. Accessibility Requirements
Accessibility is a judging criterion, not a stretch goal. The following requirements are mandatory for submission. They must be tested on a real device before the final submission ZIP is created.

## 5.1 VoiceOver Labels (Complete List)

## 5.2 Reduce Motion
Canvas stroke fade: Replace exponential decay with instant removal after 30 seconds. No gradual fade animation.
Night selection transition: Replace gradient animation with instant color switch.
Card scale effect on tap: Remove scale animation. Use opacity flash instead (0.7 opacity for 100ms).
Bloom effect: Remove scale spike. The extra-thick stroke appears but does not animate in.
Diya pulse: Replace continuous sinusoidal animation with a static glow at 70% opacity.
Canvas entry lattice: Dots appear instantly at full opacity rather than fading in.

## 5.3 Reduce Transparency
All glass cards: .ultraThinMaterial falls back to a solid fill using the night's primary color at 90% opacity. The glassEffect() modifier automatically adapts to this system setting.
Floating toolbar: Solid dark background (#1A1A1A, 95% opacity) replaces glass material.
Rhythm Bar: Same solid treatment. BPM text contrast ratio must remain > 4.5:1 against the solid background.

## 5.4 Dynamic Type
All text in the UI must use SwiftUI's automatic Dynamic Type scaling. Do not hardcode font sizes in points using .font(.system(size: N)). Use semantic sizes: .title, .headline, .body, .caption. The only exceptions are the BPM readout (use .font(.monospacedDigit()) with .largeTitle), the app title (locked at .largeTitle for visual design integrity), and the evocative word (locked at .title for design integrity — both tested at Accessibility XXL to ensure no clipping).



# 6. Constraint Compliance
## 6.1 The 25MB Limit


## 6.2 The Offline Mandate

## 6.3 The 3-Minute Rule
The Golden Path documented in Section 1.2 completes in 2 minutes 30 seconds. The 30-second buffer accommodates a slower reader on the poem, a brief pause to explore the symmetry toggle, or hesitation at the Night selection. No additional features should be added that could lengthen the critical path.


## 6.4 Platform Requirements



# 7. Build Roadmap
Seven weeks. Four phases. Each phase has a binary milestone: either it's done or it's not. No partial credit. If a milestone is not met, cut scope from the next phase — never from the current one.

## Phase 1 — The Heartbeat (Weeks 1–2)

Task 1.1: Create .swiftpm project in Swift Playgrounds or Xcode 26. Verify it opens correctly on iPad.
Task 1.2: Implement RhythmEngine with AVAudioSession and AVAudioEngine configuration. Request mic permission.
Task 1.3: Implement BeatDetector with vDSP_maxv peak detection. No calibration yet — use hardcoded threshold of 0.2.
Task 1.4: Implement a minimal CanvasScreen: black background, TimelineView, draws one white circle at center on every BeatEvent.
Task 1.5: Implement HapticController. Fire a standard UIImpactFeedbackGenerator on each BeatEvent.
Task 1.6: Test on real device in Airplane Mode. Confirm clap → circle → haptic in under 50ms perceived latency.

What is explicitly NOT built in Phase 1: Symmetry. Night system. Polar coordinates. Eulerian logic. Liquid Glass. All of these are Phase 2+.

## Phase 2 — The Geometry Engine (Weeks 3–5)

Task 2.1: Implement PolarStroke model and PolarDrawingEngine. Replace circle drawing with polar coordinate stroke drawing.
Task 2.2: Implement SymmetryRenderer with 6-fold mirroring (Night 3 default). Confirm existing strokes mirror correctly.
Task 2.3: Implement the beat-to-stroke mapping table from Section 3.3. Connect amplitude → weight, rms → opacity.
Task 2.4: Implement BPMTracker with 16-beat rolling median. Display BPM in a temporary debug label.
Task 2.5: Implement RangoliLattice for Night 3 (9x9 radial dot grid). Implement burst phase (first 30 beats = radial lines only).
Task 2.6: Implement Eulerian path pre-computation using Hierholzer's algorithm. Verify the lattice phase activates after beat 30 and draws lattice connections.
Task 2.7: Implement stroke opacity decay (×0.9992 per frame). Verify mandala fades gracefully when user stops.
Task 2.8: Implement TapGestureRecognizer fallback. Verify tapping canvas fires BeatEvent.
Task 2.9: Implement Night model with all three nights (Night 1, 3, 8). Implement Night 1 (4-fold, square lattice) and Night 8 (8-fold, radial dense lattice).
Task 2.10: Implement ambient calibration (5-second measurement on first launch). Store ambientFloor. Replace hardcoded threshold.
CHECK FILE SIZE at end of Phase 2. zip -r Avart.zip Avart.swiftpm && du -sh Avart.zip. Must be < 5MB.

## Phase 3 — The Delight Pass (Week 6)

Task 3.1: Build LaunchScreen with diya (procedural Canvas glow), ambient reactivity, and two buttons.
Task 3.2: Build NightSelectionScreen with three glass cards, scroll behavior, gradient transition on selection, and 3-second audio preview.
Task 3.3: Apply Liquid Glass to all UI surfaces: GlassCard component, floating toolbar, Rhythm Bar. Use glassEffect() and .ultraThinMaterial.
Task 3.4: Implement ReflectionScreen with frozen mandala snapshot, Foundation Models poem generation, loading shimmer, and export button.
Task 3.5: Implement PassiveSequencer for 'Start the Cycle' mode.
Task 3.6: Implement all animations from Section 4.3 inventory. Pay particular attention to the symmetry toggle re-mirror animation — this is the single most memorable visual moment.
Task 3.7: Implement CoreHaptics patterns (replace UIImpactFeedbackGenerator with CHHapticEngine for all three pattern types).
Task 3.8: Implement bloom effect for high-amplitude beats.
Task 3.9: Implement the 3-minute Golden Path demo mode. Pre-program a 90-second passive sequence that is triggered automatically if the app has been idle on the Launch Screen for more than 8 seconds.

## Phase 4 — Submission (Week 7)

Task 4.1: ACCESSIBILITY AUDIT. Enable VoiceOver. Navigate every screen. Verify every label from Section 5.1 is present and reads correctly.
Task 4.2: Enable Reduce Motion in Settings. Complete full Golden Path. Verify no animations cause confusion or clip content.
Task 4.3: Enable Reduce Transparency. Verify all glass surfaces fall back to solid fills with readable contrast.
Task 4.4: Test at Accessibility XXL text size. Verify no clipping.
Task 4.5: Final file size audit: du -sh Avart.swiftpm. du -sh Resources/. zip -r Avart.zip Avart.swiftpm && du -sh Avart.zip.
Task 4.6: AIRPLANE MODE TEST. On a real iPad. Cold launch (force quit first). Complete the full Golden Path without any network. Confirm FoundationModels generates poem offline.
Task 4.7: Write all three essay responses. Use the Feature-Problem-Solution framework for the tech prompt. Use the community workshop story for the impact prompt. Review AI disclosure language.
Task 4.8: Record the Golden Path video (if video is accepted/optional). Ensure audio is clear. The video should show clapping creating art in real time.
Task 4.9: Submit. Verify the ZIP contains a flat structure — no nested folders.



# 8. What Not to Build
This section is as important as the feature specifications. Every item listed here is something a developer might reasonably add — and should not. The enemy of a Distinguished Winner is scope creep disguised as polish.




# 9. Final Submission Checklist
This checklist must be completed in order. Do not submit until every row is checked. Each item maps to a disqualification risk or judging criterion.




A Note to the Engineer
Otto won because it did three things brilliantly.
Avart wins because it does one thing unforgettably.
That thing is this: a clap becomes a Rangoli.
Every engineering decision in this document exists to protect that moment.
Build that moment first. Build everything else second.

— End of PRD —