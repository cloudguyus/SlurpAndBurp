import Foundation

public enum LevelID: String, Codable, CaseIterable, Sendable {
    case picnic
    case kitchen
    case backyard
    case city

    public var next: LevelID? {
        switch self {
        case .picnic: return .kitchen
        case .kitchen: return .backyard
        case .backyard: return .city
        case .city: return nil
        }
    }
}

public struct LevelDefinition: Equatable, Sendable {
    public let id: LevelID
    public let name: String
    public let blurb: String
    public let duration: TimeInterval
    public let arenaRadius: Float
    public let props: [PropSpawn]
    public let hints: [String]

    public init(
        id: LevelID,
        name: String,
        blurb: String,
        duration: TimeInterval,
        arenaRadius: Float,
        props: [PropSpawn],
        hints: [String]
    ) {
        self.id = id
        self.name = name
        self.blurb = blurb
        self.duration = duration
        self.arenaRadius = arenaRadius
        self.props = props
        self.hints = hints
    }

    public var totalMass: Float {
        props.reduce(0) { $0 + $1.mass }
    }

    public static let roundDuration: TimeInterval = 120
}

public enum LevelCatalog {
    public static let all: [LevelDefinition] = LevelID.allCases.map { level($0) }

    public static func level(_ id: LevelID) -> LevelDefinition {
        switch id {
        case .picnic:
            return make(
                id: .picnic,
                name: "Picnic Blanket",
                blurb: "Grapes first. The basket is the boss.",
                arena: 12,
                seed: 0x51C0_A11,
                requests: [
                    (.grape, 16), (.napkin, 6), (.cookie, 8), (.plate, 4),
                    (.cupcake, 5), (.sandwich, 4), (.thermos, 2), (.cooler, 1), (.basket, 1),
                ],
                hints: [
                    "Drag to roll the hole.",
                    "Anything smaller than you tips in.",
                    "Keep eating. Bigger snacks start to fit.",
                ]
            )
        case .kitchen:
            return make(
                id: .kitchen,
                name: "Kitchen Rush",
                blurb: "Spoons, then chairs, then the fridge.",
                arena: 16,
                seed: 0xC11C_4E2,
                requests: [
                    (.spoon, 8), (.spatula, 5), (.mug, 8), (.kettle, 3),
                    (.toaster, 3), (.pot, 4), (.chair, 4), (.table, 1), (.fridge, 1),
                ],
                hints: ["Utensils tumble in. The fridge does not, yet."]
            )
        case .backyard:
            return make(
                id: .backyard,
                name: "Backyard Bash",
                blurb: "Toys and gnomes, then the doghouse.",
                arena: 18,
                seed: 0xBACC_0A5,
                requests: [
                    (.ball, 8), (.frisbee, 5), (.gnome, 6), (.wateringCan, 3),
                    (.planter, 3), (.grill, 2), (.bike, 2), (.doghouse, 1),
                ],
                hints: ["Chase the toys. The doghouse is a finale."]
            )
        case .city:
            return make(
                id: .city,
                name: "City Block",
                blurb: "Cones, cars, kiosks, then a building.",
                arena: 24,
                seed: 0xC175_B10C,
                requests: [
                    (.cone, 12), (.hydrant, 4), (.trashCan, 4), (.bench, 4),
                    (.car, 5), (.tree, 4), (.kiosk, 2), (.building, 3),
                ],
                hints: ["The block is big. Start with the cones."]
            )
        }
    }

    private static func make(
        id: LevelID,
        name: String,
        blurb: String,
        arena: Float,
        seed: UInt64,
        requests: [(PropKind, Int)],
        hints: [String]
    ) -> LevelDefinition {
        var kinds: [PropKind] = []
        for (kind, count) in requests {
            for _ in 0..<count {
                kinds.append(kind)
            }
        }
        let order = kinds.enumerated().sorted { lhs, rhs in
            if lhs.element.radius == rhs.element.radius {
                return lhs.offset < rhs.offset
            }
            return lhs.element.radius < rhs.element.radius
        }
        let masses = balancedMasses(radii: order.map { $0.element.radius })
        var massByOrdinal: [Int: Float] = [:]
        for (index, item) in order.enumerated() {
            massByOrdinal[item.offset] = masses[index]
        }

        var rng = SplitMix64(seed: seed)
        var placed: [PropSpawn] = []
        for (ordinal, kind) in kinds.enumerated() {
            let radius = kind.radius
            let t = Float(ordinal) / Float(max(kinds.count - 1, 1))
            let preferred = 2.3 + t * (arena * 0.84 - 2.3)
            var position = Vec2.zero
            var yaw: Float = 0
            var found = false
            for _ in 0..<90 {
                let angle = rng.nextFloat() * 2 * Float.pi
                let ring = preferred * (0.72 + 0.5 * rng.nextFloat())
                let candidate = Vec2(x: cosf(angle) * ring, y: sinf(angle) * ring)
                let reach = candidate.length
                if reach < 1.7 || reach > arena * 0.9 { continue }
                let clear = placed.allSatisfy { other in
                    candidate.distance(to: other.position) >= (radius + other.radius) * 0.92
                }
                if clear {
                    position = candidate
                    yaw = rng.nextFloat() * 2 * Float.pi
                    found = true
                    break
                }
            }
            if !found {
                let angle = Float(ordinal) * 2.3999632
                let ring = min(arena * 0.88, 2.1 + Float(ordinal) * 0.48)
                position = Vec2(x: cosf(angle) * ring, y: sinf(angle) * ring)
                yaw = rng.nextFloat() * 2 * Float.pi
            }
            let mass = massByOrdinal[ordinal] ?? 0.2
            placed.append(
                PropSpawn(
                    id: ordinal + 1,
                    kind: kind,
                    position: position,
                    yaw: yaw,
                    radius: radius,
                    height: kind.height,
                    mass: mass,
                    score: ScoreRules.points(forRadius: radius)
                )
            )
        }

        return LevelDefinition(
            id: id,
            name: name,
            blurb: blurb,
            duration: LevelDefinition.roundDuration,
            arenaRadius: arena,
            props: placed,
            hints: hints
        )
    }

    /// Masses that keep every prop reachable in small-to-large order, without
    /// letting the first bite unlock the boss. Deficits are shared by the
    /// previous size class, weighted toward the larger of those bites.
    static func balancedMasses(radii: [Float]) -> [Float] {
        var masses = radii.map { radius -> Float in
            max(0.07, radius * radius * 0.62)
        }
        guard !radii.isEmpty else { return masses }

        func massBefore(_ index: Int) -> Float {
            var total = GrowthCurve.startingMass
            if index > 0 {
                for cursor in 0..<index {
                    total += masses[cursor]
                }
            }
            return total
        }

        for index in radii.indices {
            let needed = GrowthCurve.minimumMass(toEat: radii[index])
            let have = massBefore(index)
            guard have + 0.02 < needed else { continue }
            precondition(index > 0, "The smallest bite has to fit in the starting hole.")
            let deficit = needed - have + 0.06
            let window = max(1, index / 3)
            let start = index - window
            var weight = Float(0)
            for cursor in start..<index {
                weight += radii[cursor] * radii[cursor]
            }
            if weight <= 0.0001 {
                masses[index - 1] += deficit
            } else {
                for cursor in start..<index {
                    let share = (radii[cursor] * radii[cursor]) / weight
                    masses[cursor] += deficit * share
                }
            }
        }
        return masses
    }
}

struct SplitMix64: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func nextFloat() -> Float {
        Float(next() & 0xFFFFFF) / Float(0x1000000)
    }
}

private func sinf(_ value: Float) -> Float { Float(sin(Double(value))) }
private func cosf(_ value: Float) -> Float { Float(cos(Double(value))) }
