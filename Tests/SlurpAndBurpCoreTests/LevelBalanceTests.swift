import XCTest
@testable import SlurpAndBurpCore

final class LevelBalanceTests: XCTestCase {
    func testFourThemedLevelsLastTwoMinutes() {
        XCTAssertEqual(LevelCatalog.all.count, 4)
        XCTAssertEqual(LevelCatalog.all.map(\.id), [.picnic, .kitchen, .backyard, .city])
        for level in LevelCatalog.all {
            XCTAssertEqual(level.duration, 120)
            XCTAssertFalse(level.props.isEmpty)
            XCTAssertFalse(level.hints.isEmpty)
        }
    }

    func testRequiredPropsExistInEachWorld() {
        assertKinds(.picnic, [
            .grape, .cookie, .sandwich, .cupcake, .basket, .plate, .napkin, .thermos, .cooler,
        ])
        assertKinds(.kitchen, [
            .spoon, .spatula, .mug, .toaster, .pot, .chair, .table, .fridge, .kettle,
        ])
        assertKinds(.backyard, [
            .ball, .frisbee, .gnome, .grill, .bike, .doghouse, .wateringCan, .planter,
        ])
        assertKinds(.city, [
            .cone, .hydrant, .trashCan, .bench, .car, .tree, .kiosk, .building,
        ])
    }

    func testLayoutsAreDeterministicAndInsideTheArena() {
        for id in LevelID.allCases {
            let first = LevelCatalog.level(id)
            let second = LevelCatalog.level(id)
            XCTAssertEqual(first.props, second.props)
            for prop in first.props {
                XCTAssertLessThanOrEqual(prop.position.length, first.arenaRadius * 0.91)
                XCTAssertGreaterThan(prop.position.length, 1.4)
                XCTAssertGreaterThan(prop.mass, 0)
                XCTAssertGreaterThan(prop.score, 0)
            }
        }
    }

    func testEveryLevelIsClearableInSmallToLargeOrder() {
        for id in LevelID.allCases {
            let level = LevelCatalog.level(id)
            let sorted = level.props.sorted { lhs, rhs in
                if lhs.radius == rhs.radius { return lhs.id < rhs.id }
                return lhs.radius < rhs.radius
            }
            var mass = GrowthCurve.startingMass
            for (index, prop) in sorted.enumerated() {
                let radius = GrowthCurve.radius(forMass: mass)
                XCTAssertTrue(
                    GrowthCurve.canEat(holeRadius: radius, objectRadius: prop.radius),
                    "\(id) cannot eat \(prop.kind.displayName) (#\(index)) at hole radius \(radius)"
                )
                mass += prop.mass
            }
        }
    }

    func testBossStaysLockedUntilTheMealIsUnderway() {
        for id in LevelID.allCases {
            let level = LevelCatalog.level(id)
            let sorted = level.props.sorted { $0.radius < $1.radius }
            let boss = try! XCTUnwrap(sorted.last)
            let start = GrowthCurve.radius(forMass: GrowthCurve.startingMass)
            XCTAssertFalse(
                GrowthCurve.canEat(holeRadius: start, objectRadius: boss.radius),
                "\(id) boss \(boss.kind.displayName) is edible immediately"
            )

            let others = sorted.dropLast()
            let otherMass = others.reduce(Float(0)) { $0 + $1.mass }
            var mass = GrowthCurve.startingMass
            var eaten: Float = 0
            var unlockedAt: Float?
            for prop in others {
                let radius = GrowthCurve.radius(forMass: mass)
                if GrowthCurve.canEat(holeRadius: radius, objectRadius: boss.radius) {
                    unlockedAt = eaten
                    break
                }
                mass += prop.mass
                eaten += prop.mass
            }
            if let unlockedAt {
                XCTAssertGreaterThan(
                    unlockedAt / otherMass,
                    0.4,
                    "\(id) boss unlocks after only \(unlockedAt) of \(otherMass) mass"
                )
            }
        }
    }

    func testClearingEveryLevelReachesALegendaryBurp() {
        for id in LevelID.allCases {
            let session = GameSession(level: LevelCatalog.level(id))
            var steps = 0
            while session.phase == .playing && steps < 20_000 {
                steps += 1
                let radius = session.holeRadius
                if let next = session.props
                    .filter({ !$0.consumed && $0.slurp <= 0 })
                    .sorted(by: { $0.radius < $1.radius })
                    .first(where: { GrowthCurve.canEat(holeRadius: radius, objectRadius: $0.radius) }) {
                    session.testingMoveHole(to: next.position)
                }
                session.tick(deltaTime: 1.0 / 30.0)
            }
            XCTAssertNotEqual(session.phase, .playing, "\(id) never cleared after \(steps) steps")
            XCTAssertEqual(session.percentEaten, 100, accuracy: 0.001)
            XCTAssertEqual(session.burp, .legendary)
            XCTAssertEqual(ScoreRules.stars(percent: session.percentEaten), 3)
            XCTAssertGreaterThan(session.finalScore, session.eatenPoints)

            var safety = 0
            while session.phase == .burping && safety < 500 {
                session.tick(deltaTime: 0.1)
                safety += 1
            }
            XCTAssertEqual(session.phase, .results)
        }
    }

    private func assertKinds(_ id: LevelID, _ kinds: [PropKind]) {
        let present = Set(LevelCatalog.level(id).props.map(\.kind))
        for kind in kinds {
            XCTAssertTrue(present.contains(kind), "\(id) is missing \(kind.rawValue)")
        }
    }
}
