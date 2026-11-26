import Foundation

/// How the end-of-round burp scales with how much of the level was eaten.
public enum BurpTier: Int, Codable, CaseIterable, Sendable {
    case hic = 0
    case polite = 1
    case hearty = 2
    case rumbling = 3
    case legendary = 4

    public var title: String {
        switch self {
        case .hic: return "A tiny hic"
        case .polite: return "A little burp"
        case .hearty: return "A hearty BURP"
        case .rumbling: return "A rumbling BURRRP"
        case .legendary: return "A legendary BURRRRRP"
        }
    }

    public var detail: String {
        switch self {
        case .hic: return "Barely a bubble."
        case .polite: return "Excuse you."
        case .hearty: return "That hit the spot."
        case .rumbling: return "The ground noticed."
        case .legendary: return "The whole map was delicious."
        }
    }

    /// How long the burp animation, sound, and shake play.
    public var duration: TimeInterval {
        switch self {
        case .hic: return 0.75
        case .polite: return 1.2
        case .hearty: return 1.75
        case .rumbling: return 2.4
        case .legendary: return 3.2
        }
    }

    /// Camera shake amplitude in world units at the peak of the burp.
    public var shake: Float {
        switch self {
        case .hic: return 0.015
        case .polite: return 0.05
        case .hearty: return 0.11
        case .rumbling: return 0.2
        case .legendary: return 0.36
        }
    }

    /// Starting pitch of the synthesized burp, in hertz. Bigger burps are lower.
    public var fundamentalHz: Double {
        switch self {
        case .hic: return 740
        case .polite: return 230
        case .hearty: return 128
        case .rumbling: return 72
        case .legendary: return 46
        }
    }

    public static func < (lhs: BurpTier, rhs: BurpTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension BurpTier: Comparable {}
