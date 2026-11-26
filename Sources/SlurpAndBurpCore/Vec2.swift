import Foundation

/// A point on the ground. `x` is world X and `y` is world Z.
public struct Vec2: Equatable, Hashable, Codable, Sendable {
    public var x: Float
    public var y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }

    public static let zero = Vec2(x: 0, y: 0)

    public var length: Float {
        (x * x + y * y).squareRoot()
    }

    public func distance(to other: Vec2) -> Float {
        (self - other).length
    }

    public func clamped(maxLength: Float) -> Vec2 {
        let len = length
        guard len > maxLength, len > 0.00001 else { return self }
        return self * (maxLength / len)
    }

    public func lerp(to other: Vec2, t: Float) -> Vec2 {
        let clamped = min(1, max(0, t))
        return self * (1 - clamped) + other * clamped
    }

    public static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Vec2, rhs: Float) -> Vec2 {
        Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    public static func * (lhs: Float, rhs: Vec2) -> Vec2 {
        rhs * lhs
    }
}
