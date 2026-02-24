import SwiftUI

/// Root navigation router. Manages screen transitions through the Golden Path.
struct ContentView: View {
    enum Screen {
        case launch
        case nightSelection
        case canvas(Night, isPassive: Bool)
        case reflection(SessionData, frozenStrokes: [PolarStroke])
    }

    @EnvironmentObject var rhythmEngine: RhythmEngine
    @State private var currentScreen: Screen = .launch
    @State private var drawingEngineRef: PolarDrawingEngine?

    var body: some View {
        ZStack {
            switch currentScreen {
            case .launch:
                LaunchScreen(
                    onStartCycle: {
                        // Passive mode: skip night selection, go to canvas with Night 3
                        rhythmEngine.requestPermissionAndSetup()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .canvas(.night3, isPassive: true)
                        }
                    },
                    onEnterCircle: {
                        // Active mode: go to night selection
                        rhythmEngine.requestPermissionAndSetup()
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .nightSelection
                        }
                    }
                )
                .transition(.opacity)

            case .nightSelection:
                NightSelectionScreen { night in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentScreen = .canvas(night, isPassive: false)
                    }
                }
                .transition(.opacity)

            case .canvas(let night, let isPassive):
                CanvasScreen(
                    night: night,
                    isPassiveMode: isPassive,
                    onReflect: { sessionData in
                        // Capture frozen strokes before transitioning
                        let frozen = drawingEngineRef?.snapshot() ?? []
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .reflection(sessionData, frozenStrokes: frozen)
                        }
                    }
                )
                .transition(.opacity)

            case .reflection(let sessionData, let frozenStrokes):
                ReflectionScreen(
                    sessionData: sessionData,
                    frozenStrokes: frozenStrokes,
                    onNewNight: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .nightSelection
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: screenID)
    }

    /// Simple screen identifier for animation tracking
    private var screenID: String {
        switch currentScreen {
        case .launch: return "launch"
        case .nightSelection: return "nightSelection"
        case .canvas: return "canvas"
        case .reflection: return "reflection"
        }
    }
}
