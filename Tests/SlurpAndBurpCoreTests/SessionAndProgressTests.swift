import XCTest
@testable import SlurpAndBurpCore

final class SessionAndProgressTests: XCTestCase {
    func testSwallowingASmallBiteGrowsTheHole() {
        let grape = PropSpawn(
            id: 1, kind: .grape, position: Vec2(x: 0.05, y: 0), yaw: 0,
            radius: PropKind.grape.radius, height: PropKind.grape.height,
            mass: 0.4, score: 12
        )
        let session = GameSession(level: emptyLevel(props: [grape]))
        let before = session.holeRadius
        var swallowed: [SwallowEvent] = []
        for _ in 0..<40 {
            swallowed.append(contentsOf: session.tick(deltaTime: 1.0 / 30.0))
        }
        XCTAssertEqual(swallowed.count, 1)
        XCTAssertEqual(swallowed[0].kind, .grape)
        XCTAssertGreaterThan(session.holeRadius, before)
        XCTAssertEqual(session.eatenCount, 1)
        XCTAssertEqual(session.percentEaten, 100, accuracy: 0.001)
        XCTAssertEqual(session.phase, .burping)
        XCTAssertEqual(session.burp, .legendary)
    }

    func testABuildingDoesNotFallInAtTheStart() {
        let building = PropSpawn(
            id: 1, kind: .building, position: .zero, yaw: 0,
            radius: PropKind.building.radius, height: PropKind.building.height,
            mass: 4, score: 400
        )
        let session = GameSession(level: emptyLevel(props: [building], arena: 30))
        session.testingMoveHole(to: .zero)
        for _ in 0..<60 {
            session.tick(deltaTime: 1.0 / 30.0)
        }
        XCTAssertEqual(session.eatenCount, 0)
        XCTAssertEqual(session.snapshot().mood, .straining)
        XCTAssertEqual(session.phase, .playing)
    }

    func testTimerExpiryBurpsAHicThenShowsResults() {
        let session = GameSession(level: emptyLevel(props: []))
        var guardCount = 0
        while session.phase == .playing && guardCount < 2_000 {
            session.tick(deltaTime: 0.25)
            guardCount += 1
        }
        XCTAssertEqual(session.phase, .burping)
        XCTAssertEqual(session.burp, .hic)
        XCTAssertEqual(session.snapshot().mood, .burping)
        XCTAssertLessThan(session.snapshot().burpProgress, 0.2)

        var safety = 0
        while session.phase == .burping && safety < 200 {
            session.tick(deltaTime: 0.2)
            safety += 1
        }
        XCTAssertEqual(session.phase, .results)
        XCTAssertEqual(session.makeResult().stars, 0)
        XCTAssertEqual(session.finalScore, 0)
    }

    func testPauseFreezesTheClockAndTheHole() {
        let session = GameSession(level: emptyLevel(props: []))
        session.steer = Vec2(x: 1, y: 0)
        session.tick(deltaTime: 0.2)
        let moved = session.holePosition
        let remaining = session.timeRemaining
        session.isPaused = true
        session.tick(deltaTime: 0.5)
        XCTAssertEqual(session.holePosition, moved)
        XCTAssertEqual(session.timeRemaining, remaining)
    }

    func testSteeringMovesAndStaysInsideTheArena() {
        let session = GameSession(level: emptyLevel(props: [], arena: 4))
        session.steer = Vec2(x: 20, y: 0)
        for _ in 0..<90 {
            session.tick(deltaTime: 1.0 / 30.0)
        }
        XCTAssertGreaterThan(session.holePosition.x, 1)
        XCTAssertLessThanOrEqual(session.holePosition.length, 4.01)
        XCTAssertEqual(session.snapshot().mood, .moving)
    }

    func testPreviewBurpUsesTheRequestedTier() {
        let session = GameSession(level: LevelCatalog.level(.city))
        session.previewBurp(percent: 92)
        XCTAssertEqual(session.phase, .burping)
        XCTAssertEqual(session.burp, .legendary)
        XCTAssertEqual(session.percentEaten, 92, accuracy: 0.001)
        XCTAssertEqual(session.snapshot().stars, 3)
    }

    func testProgressKeepsTheBestRunAndRoundTripsThroughDefaults() {
        var book = ProgressBook()
        let weak = result(score: 100, percent: 30, stars: 1)
        let strong = result(score: 800, percent: 90, stars: 3)
        let tiedButFuller = result(score: 800, percent: 96, stars: 3)
        let worse = result(score: 400, percent: 99, stars: 3)
        XCTAssertTrue(book.record(weak))
        XCTAssertTrue(book.record(strong))
        XCTAssertFalse(book.record(worse))
        XCTAssertTrue(book.record(tiedButFuller))
        XCTAssertEqual(book.best(for: .kitchen)?.score, 800)
        XCTAssertEqual(book.best(for: .kitchen)?.percent ?? 0, 96, accuracy: 0.001)

        let suiteName = "SlurpTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        ProgressStore.save(book, to: defaults, key: "test")
        let loaded = ProgressStore.load(from: defaults, key: "test")
        XCTAssertEqual(loaded, book)
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func emptyLevel(props: [PropSpawn], arena: Float = 10) -> LevelDefinition {
        LevelDefinition(
            id: .picnic,
            name: "Test",
            blurb: "Test",
            duration: 120,
            arenaRadius: arena,
            props: props,
            hints: ["Test"]
        )
    }

    private func result(score: Int, percent: Double, stars: Int) -> RoundResult {
        RoundResult(
            level: .kitchen,
            score: score,
            percent: percent,
            stars: stars,
            burp: ScoreRules.burpTier(percent: percent),
            eatenCount: 1,
            totalCount: 4
        )
    }
}
