import SwiftUI

/// A single stroke in polar coordinates, drawn outward from the mandala center.
/// Each stroke is mirrored N times by the SymmetryRenderer.
struct PolarStroke: Identifiable {
    let id = UUID()
    var angle: Double          // Radians from center (0–2π)
    var radius: Double         // Start distance from center (pts)
    var endRadius: Double      // End distance from center (pts)
    var arcLength: Double      // Angular span of the curve (radians)
    var weight: CGFloat        // Stroke width (1–8pt)
    var color: Color           // Night palette color
    var opacity: Double        // Current alpha (decays each frame)
    var controlOffset: CGSize  // Bezier control point offset for curvature
    var isLatticeStroke: Bool  // true if part of Eulerian lattice phase

    /// Decay the stroke opacity by the per-frame factor.
    /// At 60fps, 0.9992^60 ≈ 0.953 per second — strokes fade over ~80 seconds.
    mutating func decay() {
        opacity *= 0.9992
    }

    /// Create a radial burst stroke (Phase 1: first 30 beats)
    static func burstStroke(
        angle: Double,
        amplitude: Float,
        rms: Float,
        color: Color
    ) -> PolarStroke {
        let weight = CGFloat(1.0 + Double(amplitude) * 7.0) // 1–8pt
        let opacity = Double(0.4 + rms * 0.6)               // 0.4–1.0
        let endRadius = Double(50 + amplitude * 200)         // Variable reach

        return PolarStroke(
            angle: angle,
            radius: 10,
            endRadius: endRadius,
            arcLength: Double.random(in: 0.02...0.15),
            weight: weight,
            color: color,
            opacity: min(opacity, 1.0),
            controlOffset: CGSize(
                width: Double.random(in: -30...30),
                height: Double.random(in: -30...30)
            ),
            isLatticeStroke: false
        )
    }

    /// Create a lattice connection stroke (Phase 2: after 30 beats)
    static func latticeStroke(
        fromAngle: Double,
        fromRadius: Double,
        toAngle: Double,
        toRadius: Double,
        amplitude: Float,
        rms: Float,
        color: Color
    ) -> PolarStroke {
        let weight = CGFloat(1.0 + Double(amplitude) * 5.0)
        let opacity = Double(0.5 + rms * 0.5)

        return PolarStroke(
            angle: fromAngle,
            radius: fromRadius,
            endRadius: toRadius,
            arcLength: toAngle - fromAngle,
            weight: weight,
            color: color,
            opacity: min(opacity, 1.0),
            controlOffset: CGSize(
                width: Double.random(in: -15...15),
                height: Double.random(in: -15...15)
            ),
            isLatticeStroke: true
        )
    }
}
