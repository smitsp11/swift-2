import SwiftUI

/// Root navigation router. Manages screen transitions through the Golden Path.
struct ContentView: View {
    enum Screen: Equatable {
        case launch
        case nightSelection
        case canvas(Night, isPassive: Bool)
        case reflection(Night)

        static func == (lhs: Screen, rhs: Screen) -> Bool {
            switch (lhs, rhs) {
            case (.launch, .launch): return true
            case (.nightSelection, .nightSelection): return true
            case (.canvas(let a, let b), .canvas(let c, let d)):
                return a == c && b == d
            case (.reflection(let a), .reflection(let b)):
                return a == b
            default: return false
            }
        }
    }

    @EnvironmentObject var rhythmEngine: RhythmEngine
    @State private var currentScreen: Screen = .launch
    @State private var reflectionData: (SessionData, [PolarStroke])?

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
                    onReflect: { sessionData, frozenStrokes in
                        reflectionData = (sessionData, frozenStrokes)
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentScreen = .reflection(night)
                        }
                    }
                )
                .transition(.opacity)

            case .reflection:
                if let (sessionData, frozenStrokes) = reflectionData {
                    ReflectionScreen(
                        sessionData: sessionData,
                        frozenStrokes: frozenStrokes,
                        onNewNight: {
                            reflectionData = nil
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentScreen = .nightSelection
                            }
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentScreen)
    }
}
