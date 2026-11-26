import Foundation

public enum SessionPhase: Equatable, Sendable {
    case playing
    case burping
    case results
}

public enum HoleMood: Equatable, Sendable {
    case idle
    case moving
    case straining
    case slurping
    case burping
}

public struct SwallowEvent: Equatable, Sendable {
    public let propID: Int
    public let kind: PropKind
    public let score: Int
    public let mass: Float
    public let radius: Float
}

public struct PropRenderState: Equatable, Sendable {
    public let id: Int
    public let kind: PropKind
    public let position: Vec2
    public let yaw: Float
    public let radius: Float
    public let height: Float
    public let slurp: Float
    public let consumed: Bool
}

public struct RoundSnapshot: Equatable, Sendable {
    public var holePosition: Vec2
    public var holeRadius: Float
    public var holeFacing: Float
    public var mood: HoleMood
    public var score: Int
    public var timeRemaining: TimeInterval
    public var percentEaten: Double
    public var stars: Int
    public var phase: SessionPhase
    public var burp: BurpTier
    public var burpProgress: Double
    public var appetiteName: String
    public var eatenCount: Int
    public var totalCount: Int
    public var props: [PropRenderState]
}

public struct RoundResult: Equatable, Sendable {
    public let level: LevelID
    public let score: Int
    public let percent: Double
    public let stars: Int
    public let burp: BurpTier
    public let eatenCount: Int
    public let totalCount: Int
}

public struct LiveProp: Equatable, Sendable {
    public let id: Int
    public let kind: PropKind
    public var position: Vec2
    public var yaw: Float
    public let radius: Float
    public let height: Float
    public let mass: Float
    public let score: Int
    public var slurp: Float
    public var consumed: Bool
}

public final class GameSession {
    public let level: LevelDefinition
    public var steer: Vec2
    public var isPaused: Bool

    public private(set) var props: [LiveProp]
    public private(set) var holePosition: Vec2
    public private(set) var holeFacing: Float
    public private(set) var holeMass: Float
    public private(set) var eatenPoints: Int
    public private(set) var eatenMass: Float
    public private(set) var eatenCount: Int
    public private(set) var timeRemaining: TimeInterval
    public private(set) var phase: SessionPhase
    public private(set) var burp: BurpTier
    public private(set) var burpTimeRemaining: TimeInterval
    public private(set) var finalScore: Int

    private let totalMass: Float
    private var previewPercent: Double?

    public init(level: LevelDefinition, holePosition: Vec2 = .zero) {
        self.level = level
        self.steer = .zero
        self.isPaused = false
        self.holePosition = holePosition
        self.holeFacing = 0
        self.holeMass = GrowthCurve.startingMass
        self.eatenPoints = 0
        self.eatenMass = 0
        self.eatenCount = 0
        self.timeRemaining = level.duration
        self.phase = .playing
        self.burp = .hic
        self.burpTimeRemaining = 0
        self.finalScore = 0
        self.totalMass = level.props.reduce(0) { $0 + $1.mass }
        self.props = level.props.map { spawn in
            LiveProp(
                id: spawn.id,
                kind: spawn.kind,
                position: spawn.position,
                yaw: spawn.yaw,
                radius: spawn.radius,
                height: spawn.height,
                mass: spawn.mass,
                score: spawn.score,
                slurp: 0,
                consumed: false
            )
        }
    }

    public var holeRadius: Float {
        GrowthCurve.radius(forMass: holeMass)
    }

    public var percentEaten: Double {
        if let previewPercent { return previewPercent }
        return ScoreRules.percent(
            eatenMass: eatenMass,
            totalMass: totalMass,
            cleared: !props.isEmpty && eatenCount == props.count
        )
    }

    /// 0 when the burp starts, 1 as it finishes. Stays at 1 on the results card.
    public var burpProgress: Double {
        switch phase {
        case .playing:
            return 0
        case .results:
            return 1
        case .burping:
            guard burp.duration > 0 else { return 1 }
            return min(1, max(0, 1 - (burpTimeRemaining / burp.duration)))
        }
    }

    /// Steps the sim forward. One call never both ends the round and finishes the burp.
    @discardableResult
    public func tick(deltaTime: TimeInterval) -> [SwallowEvent] {
        if isPaused || deltaTime <= 0 { return [] }
        var budget = min(deltaTime, 0.25)
        var events: [SwallowEvent] = []
        let started = phase
        while budget > 0.00001 {
            if started == .playing, phase != .playing { break }
            let step = min(budget, 1.0 / 30.0)
            events.append(contentsOf: advance(by: step))
            budget -= step
            if started == .playing, phase != .playing { break }
        }
        return events
    }

    public func snapshot() -> RoundSnapshot {
        let percent = percentEaten
        return RoundSnapshot(
            holePosition: holePosition,
            holeRadius: holeRadius,
            holeFacing: holeFacing,
            mood: currentMood(),
            score: phase == .playing ? eatenPoints : finalScore,
            timeRemaining: timeRemaining,
            percentEaten: percent,
            stars: ScoreRules.stars(percent: percent),
            phase: phase,
            burp: burp,
            burpProgress: burpProgress,
            appetiteName: GrowthCurve.appetiteName(radius: holeRadius),
            eatenCount: eatenCount,
            totalCount: props.count,
            props: props.map { prop in
                PropRenderState(
                    id: prop.id,
                    kind: prop.kind,
                    position: prop.position,
                    yaw: prop.yaw,
                    radius: prop.radius,
                    height: prop.height,
                    slurp: prop.slurp,
                    consumed: prop.consumed
                )
            }
        )
    }

    public func makeResult() -> RoundResult {
        let percent = percentEaten
        return RoundResult(
            level: level.id,
            score: finalScore,
            percent: percent,
            stars: ScoreRules.stars(percent: percent),
            burp: burp,
            eatenCount: eatenCount,
            totalCount: props.count
        )
    }

    /// Holds a burp for screenshots and previews without playing the round.
    public func previewBurp(percent: Double) {
        let clamped = min(100, max(0, percent))
        previewPercent = clamped
        burp = ScoreRules.burpTier(percent: clamped)
        finalScore = ScoreRules.totalScore(
            eatenPoints: eatenPoints,
            percent: clamped,
            timeRemaining: timeRemaining
        )
        phase = .burping
        burpTimeRemaining = burp.duration
    }

    func testingMoveHole(to position: Vec2) {
        holePosition = position
    }

    public func currentMood() -> HoleMood {
        switch phase {
        case .burping, .results:
            return .burping
        case .playing:
            break
        }
        if props.contains(where: { $0.slurp > 0 && !$0.consumed }) {
            return .slurping
        }
        let mouth = holeRadius * 0.78
        let straining = props.contains { prop in
            !prop.consumed
                && prop.position.distance(to: holePosition) <= mouth
                && !GrowthCurve.canEat(holeRadius: holeRadius, objectRadius: prop.radius)
        }
        if straining { return .straining }
        if steer.length > 0.05 { return .moving }
        return .idle
    }

    private func advance(by deltaTime: TimeInterval) -> [SwallowEvent] {
        let dt = Float(deltaTime)
        switch phase {
        case .burping:
            burpTimeRemaining = max(0, burpTimeRemaining - deltaTime)
            if burpTimeRemaining <= 0 {
                phase = .results
            }
            return []
        case .results:
            return []
        case .playing:
            break
        }

        timeRemaining = max(0, timeRemaining - deltaTime)
        let steerClamped = steer.clamped(maxLength: 1)
        if steerClamped.length > 0.04 {
            let step = GrowthCurve.moveSpeed(radius: holeRadius) * dt
            holePosition = holePosition + steerClamped * step
            holeFacing = atan2f(steerClamped.x, -steerClamped.y)
        }
        clampHoleInsideArena()

        var events: [SwallowEvent] = []
        let mouth = holeRadius * GrowthCurve.mouthFraction
        for index in props.indices {
            if props[index].consumed { continue }
            if props[index].slurp <= 0 {
                let distance = props[index].position.distance(to: holePosition)
                if distance <= mouth,
                   GrowthCurve.canEat(holeRadius: holeRadius, objectRadius: props[index].radius) {
                    props[index].slurp = 0.0001
                }
            }
            if props[index].slurp > 0 {
                props[index].slurp = min(1, props[index].slurp + dt / 0.36)
                let pull = min(0.55, dt * 7.5)
                props[index].position = props[index].position.lerp(to: holePosition, t: pull)
                if props[index].slurp >= 1 {
                    props[index].consumed = true
                    props[index].position = holePosition
                    holeMass += props[index].mass
                    eatenMass += props[index].mass
                    eatenPoints += props[index].score
                    eatenCount += 1
                    events.append(
                        SwallowEvent(
                            propID: props[index].id,
                            kind: props[index].kind,
                            score: props[index].score,
                            mass: props[index].mass,
                            radius: props[index].radius
                        )
                    )
                }
            }
        }

        let cleared = eatenCount == props.count && !props.isEmpty
        if timeRemaining <= 0 || cleared {
            finishRound()
        }
        return events
    }

    private func finishRound() {
        for index in props.indices where props[index].slurp > 0 && !props[index].consumed {
            props[index].consumed = true
            props[index].slurp = 1
            holeMass += props[index].mass
            eatenMass += props[index].mass
            eatenPoints += props[index].score
            eatenCount += 1
        }
        let percent = percentEaten
        burp = ScoreRules.burpTier(percent: percent)
        finalScore = ScoreRules.totalScore(
            eatenPoints: eatenPoints,
            percent: percent,
            timeRemaining: timeRemaining
        )
        phase = .burping
        burpTimeRemaining = burp.duration
    }

    private func clampHoleInsideArena() {
        let limit = max(0.8, level.arenaRadius - holeRadius * 0.2)
        let distance = holePosition.length
        if distance > limit, distance > 0 {
            holePosition = holePosition * (limit / distance)
        }
    }
}

private func atan2f(_ y: Float, _ x: Float) -> Float {
    Float(atan2(Double(y), Double(x)))
}
