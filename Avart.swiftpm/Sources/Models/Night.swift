import SwiftUI

/// Represents the three Navratri nights available in Avart.
/// Each night carries its own goddess, color palette, symmetry fold, and lattice configuration.
enum Night: Int, CaseIterable, Identifiable {
    case night1 = 1
    case night3 = 3
    case night8 = 8

    var id: Int { rawValue }

    // MARK: - Cultural Identity

    var goddessName: String {
        switch self {
        case .night1: return "Shailputri"
        case .night3: return "Chandraghanta"
        case .night8: return "Mahagauri"
        }
    }

    var goddessGujarati: String {
        switch self {
        case .night1: return "શૈલપુત્રી"
        case .night3: return "ચંદ્રઘંટા"
        case .night8: return "મહાગૌરી"
        }
    }

    var culturalAttributes: String {
        switch self {
        case .night1: return "Nature, purity, and new beginnings"
        case .night3: return "Bravery, focus, and inner strength"
        case .night8: return "Radiance, grace, and transcendence"
        }
    }

    // MARK: - Color Palette

    var primaryColor: Color {
        switch self {
        case .night1: return Color(red: 0.80, green: 0.36, blue: 0.36)   // Vermillion
        case .night3: return Color(red: 1.0, green: 0.55, blue: 0.0)     // Amber
        case .night8: return Color(red: 0.36, green: 0.42, blue: 0.75)   // Indigo
        }
    }

    var secondaryColor: Color {
        switch self {
        case .night1: return Color(red: 0.85, green: 0.65, blue: 0.13)   // Gold
        case .night3: return Color(red: 0.85, green: 0.65, blue: 0.13)   // Gold
        case .night8: return Color(red: 0.58, green: 0.44, blue: 0.86)   // Lavender
        }
    }

    var accentColor: Color {
        switch self {
        case .night1: return Color(red: 0.90, green: 0.70, blue: 0.20)   // Warm Gold
        case .night3: return Color(red: 1.0, green: 0.65, blue: 0.15)    // Deep Amber
        case .night8: return Color(red: 0.75, green: 0.85, blue: 1.0)    // Moonlight
        }
    }

    /// Colors used for drawing strokes on the canvas
    var strokeColors: [Color] {
        switch self {
        case .night1: return [primaryColor, secondaryColor, accentColor, Color(red: 0.95, green: 0.45, blue: 0.30)]
        case .night3: return [primaryColor, secondaryColor, accentColor, Color(red: 1.0, green: 0.75, blue: 0.30)]
        case .night8: return [primaryColor, secondaryColor, accentColor, Color(red: 0.85, green: 0.75, blue: 1.0)]
        }
    }

    /// Background gradient for this night
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.02, blue: 0.0),
                primaryColor.opacity(0.25),
                Color(red: 0.05, green: 0.02, blue: 0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Geometry Configuration

    /// Default symmetry fold for this night
    var defaultSymmetryFold: Int {
        switch self {
        case .night1: return 4
        case .night3: return 6
        case .night8: return 8
        }
    }

    /// Lattice grid dimension (N×N)
    var latticeSize: Int {
        switch self {
        case .night1: return 5
        case .night3: return 9
        case .night8: return 13
        }
    }

    /// Whether lattice uses radial or square arrangement
    var isRadialLattice: Bool {
        switch self {
        case .night1: return false
        case .night3: return true
        case .night8: return true
        }
    }

    /// Primary geometry description for reflection prompt
    var primaryGeometry: String {
        switch self {
        case .night1: return "square"
        case .night3: return "triangular"
        case .night8: return "octagonal"
        }
    }
}
