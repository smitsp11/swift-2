import SwiftUI

/// Renders PolarStrokes with N-fold dihedral symmetry.
/// Each stroke is drawn N times rotated by 2π/N around the canvas center.
struct SymmetryRenderer {

    /// Draw all strokes with the given symmetry fold into a Canvas GraphicsContext.
    static func draw(
        strokes: [PolarStroke],
        symmetryFold: Int,
        in context: inout GraphicsContext,
        size: CGSize
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let sliceAngle = (2 * Double.pi) / Double(symmetryFold)

        for stroke in strokes {
            for i in 0..<symmetryFold {
                let rotationAngle = sliceAngle * Double(i)

                // Save context state
                var ctx = context
                // Translate to center, rotate, translate back
                ctx.translateBy(x: center.x, y: center.y)
                ctx.rotate(by: .radians(rotationAngle))

                // Draw the stroke
                let path = buildStrokePath(stroke: stroke)

                ctx.stroke(
                    path,
                    with: .color(stroke.color.opacity(stroke.opacity)),
                    lineWidth: stroke.weight
                )

                // Also draw the mirror (for full dihedral symmetry, not just rotation)
                var mirrorCtx = context
                mirrorCtx.translateBy(x: center.x, y: center.y)
                mirrorCtx.rotate(by: .radians(rotationAngle))
                mirrorCtx.scaleBy(x: 1, y: -1)

                mirrorCtx.stroke(
                    path,
                    with: .color(stroke.color.opacity(stroke.opacity * 0.85)),
                    lineWidth: stroke.weight * 0.9
                )
            }
        }
    }

    /// Build a Bezier path for a single stroke in local (centered) coordinates.
    private static func buildStrokePath(stroke: PolarStroke) -> Path {
        Path { path in
            if stroke.isLatticeStroke {
                // Lattice stroke: line between two polar positions
                let startX = stroke.radius * cos(stroke.angle)
                let startY = stroke.radius * sin(stroke.angle)
                let endAngle = stroke.angle + stroke.arcLength
                let endX = stroke.endRadius * cos(endAngle)
                let endY = stroke.endRadius * sin(endAngle)

                path.move(to: CGPoint(x: startX, y: startY))
                path.addCurve(
                    to: CGPoint(x: endX, y: endY),
                    control1: CGPoint(
                        x: (startX + endX) / 2 + stroke.controlOffset.width,
                        y: (startY + endY) / 2 + stroke.controlOffset.height
                    ),
                    control2: CGPoint(
                        x: (startX + endX) / 2 - stroke.controlOffset.width * 0.5,
                        y: (startY + endY) / 2 - stroke.controlOffset.height * 0.5
                    )
                )
            } else {
                // Burst stroke: radial line outward from near-center
                let startX = stroke.radius * cos(stroke.angle)
                let startY = stroke.radius * sin(stroke.angle)
                let endX = stroke.endRadius * cos(stroke.angle + stroke.arcLength)
                let endY = stroke.endRadius * sin(stroke.angle + stroke.arcLength)

                path.move(to: CGPoint(x: startX, y: startY))
                path.addCurve(
                    to: CGPoint(x: endX, y: endY),
                    control1: CGPoint(
                        x: startX + stroke.controlOffset.width,
                        y: startY + stroke.controlOffset.height
                    ),
                    control2: CGPoint(
                        x: endX - stroke.controlOffset.width * 0.3,
                        y: endY - stroke.controlOffset.height * 0.3
                    )
                )
            }
        }
    }

    /// Draw the dot lattice grid as faint background dots
    static func drawLattice(
        dots: [CGPoint],
        night: Night,
        in context: inout GraphicsContext,
        size: CGSize,
        opacity: Double = 0.3
    ) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        for dot in dots {
            let screenPos = CGPoint(
                x: center.x + dot.x,
                y: center.y + dot.y
            )
            let dotSize: CGFloat = 3.0
            let rect = CGRect(
                x: screenPos.x - dotSize / 2,
                y: screenPos.y - dotSize / 2,
                width: dotSize,
                height: dotSize
            )
            context.fill(
                Path(ellipseIn: rect),
                with: .color(night.primaryColor.opacity(opacity))
            )
        }
    }
}
