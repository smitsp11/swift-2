import SwiftUI

/// @main entry point for Avart.
@main
struct AvartApp: App {
    @StateObject private var rhythmEngine = RhythmEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(rhythmEngine)
                .preferredColorScheme(.dark)
                .onAppear {
                    HapticController.shared.prepare()
                }
        }
    }
}
