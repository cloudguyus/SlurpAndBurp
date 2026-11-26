import Foundation

/// How the hole's mouth widens as it swallows mass.
///
/// Radius follows `baseRadius * mass ^ exponent`. An object falls in only when
/// its footprint is at most `edibleFraction` of that radius, so the rim has to
/// really cover it. Bigger bites unlock the next size tier; they do not skip it.
public enum GrowthCurve {
    public static let startingMass: Float = 1
    public static let baseRadius: Float = 0.64
    public static let exponent: Float = 0.42
    public static let maxRadius: Float = 16
    /// Object radius must be this fraction of the hole (or smaller) to be edible.
    public static let edibleFraction: Float = 0.84
    /// The object's center has to sit this far inside the hole before it tips.
    public static let mouthFraction: Float = 0.62

    public static func radius(forMass mass: Float) -> Float {
        let safe = max(mass, 0.001)
        let grown = baseRadius * powf(safe, exponent)
        return min(maxRadius, grown)
    }

    public static func canEat(holeRadius: Float, objectRadius: Float) -> Bool {
        objectRadius <= holeRadius * edibleFraction + 0.0001
    }

    /// Smallest mass whose mouth can swallow an object of `objectRadius`.
    public static func minimumMass(toEat objectRadius: Float) -> Float {
        let neededHole = objectRadius / edibleFraction
        if neededHole <= baseRadius {
            return startingMass
        }
        return powf(neededHole / baseRadius, 1 / exponent)
    }

    public static func appetiteName(radius: Float) -> String {
        switch radius {
        case ..<0.85: return "Nibble"
        case ..<1.35: return "Snack"
        case ..<2.2: return "Hungry"
        case ..<3.4: return "Gulping"
        default: return "Bottomless"
        }
    }

    public static func moveSpeed(radius: Float) -> Float {
        max(3.1, 6.6 - radius * 0.2)
    }
}

func powf(_ base: Float, _ exponent: Float) -> Float {
    Float(pow(Double(base), Double(exponent)))
}
