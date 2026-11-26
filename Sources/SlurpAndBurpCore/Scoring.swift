import Foundation

public enum ScoreRules {
    /// Stars from the percent of the level's mass that fell in.
    public static func stars(percent: Double) -> Int {
        switch percent {
        case 75...: return 3
        case 45..<75: return 2
        case 20..<45: return 1
        default: return 0
        }
    }

    public static func caption(stars: Int) -> String {
        switch stars {
        case 3: return "Clean plate!"
        case 2: return "A solid meal"
        case 1: return "Still hungry"
        default: return "Mostly crumbs"
        }
    }

    public static func burpTier(percent: Double) -> BurpTier {
        switch percent {
        case 85...: return .legendary
        case 55..<85: return .rumbling
        case 30..<55: return .hearty
        case 10..<30: return .polite
        default: return .hic
        }
    }

    public static func percent(eatenMass: Float, totalMass: Float, cleared: Bool) -> Double {
        if cleared { return 100 }
        guard totalMass > 0 else { return 0 }
        return min(100, Double(eatenMass / totalMass) * 100)
    }

    /// Points shown on the results card. Time left only pays out when the round ends,
    /// and clearing the map adds a flat bonus on top of what each bite was worth.
    public static func totalScore(eatenPoints: Int, percent: Double, timeRemaining: TimeInterval) -> Int {
        let timeBonus = Int(max(0, timeRemaining).rounded(.down)) * 3
        let clearBonus = percent >= 99.5 ? 750 : 0
        return eatenPoints + timeBonus + clearBonus
    }

    public static func points(forRadius radius: Float) -> Int {
        max(8, Int((radius * radius * 80).rounded()))
    }
}
