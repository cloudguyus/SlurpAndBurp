import XCTest
@testable import SlurpAndBurpCore

final class GrowthAndScoreTests: XCTestCase {
    func testRadiusGrowsWithMassAndStaysCapped() {
        let start = GrowthCurve.radius(forMass: GrowthCurve.startingMass)
        let heavier = GrowthCurve.radius(forMass: 8)
        let huge = GrowthCurve.radius(forMass: 10_000)
        XCTAssertGreaterThan(heavier, start)
        XCTAssertLessThanOrEqual(huge, GrowthCurve.maxRadius)
        XCTAssertEqual(start, GrowthCurve.baseRadius, accuracy: 0.0001)
    }

    func testStartingHoleEatsAGrapeAndNotABasket() {
        let radius = GrowthCurve.radius(forMass: GrowthCurve.startingMass)
        XCTAssertTrue(GrowthCurve.canEat(holeRadius: radius, objectRadius: PropKind.grape.radius))
        XCTAssertFalse(GrowthCurve.canEat(holeRadius: radius, objectRadius: PropKind.basket.radius))
        XCTAssertFalse(GrowthCurve.canEat(holeRadius: radius, objectRadius: PropKind.fridge.radius))
        XCTAssertFalse(GrowthCurve.canEat(holeRadius: radius, objectRadius: PropKind.building.radius))
    }

    func testStarThresholds() {
        XCTAssertEqual(ScoreRules.stars(percent: 0), 0)
        XCTAssertEqual(ScoreRules.stars(percent: 19.9), 0)
        XCTAssertEqual(ScoreRules.stars(percent: 20), 1)
        XCTAssertEqual(ScoreRules.stars(percent: 44.9), 1)
        XCTAssertEqual(ScoreRules.stars(percent: 45), 2)
        XCTAssertEqual(ScoreRules.stars(percent: 74.9), 2)
        XCTAssertEqual(ScoreRules.stars(percent: 75), 3)
        XCTAssertEqual(ScoreRules.stars(percent: 100), 3)
    }

    func testBurpTiersScaleWithPercentAndGetBigger() {
        XCTAssertEqual(ScoreRules.burpTier(percent: 0), .hic)
        XCTAssertEqual(ScoreRules.burpTier(percent: 9.9), .hic)
        XCTAssertEqual(ScoreRules.burpTier(percent: 10), .polite)
        XCTAssertEqual(ScoreRules.burpTier(percent: 29.9), .polite)
        XCTAssertEqual(ScoreRules.burpTier(percent: 30), .hearty)
        XCTAssertEqual(ScoreRules.burpTier(percent: 54.9), .hearty)
        XCTAssertEqual(ScoreRules.burpTier(percent: 55), .rumbling)
        XCTAssertEqual(ScoreRules.burpTier(percent: 84.9), .rumbling)
        XCTAssertEqual(ScoreRules.burpTier(percent: 85), .legendary)
        XCTAssertEqual(ScoreRules.burpTier(percent: 100), .legendary)

        var previous = 0.0
        for tier in BurpTier.allCases {
            XCTAssertGreaterThan(tier.duration, previous)
            previous = tier.duration
        }
        XCTAssertLessThan(BurpTier.hic.shake, BurpTier.legendary.shake)
        XCTAssertGreaterThan(BurpTier.hic.fundamentalHz, BurpTier.legendary.fundamentalHz)
        XCTAssertLessThan(BurpTier.hic, BurpTier.legendary)
    }

    func testScorePaysTimeAndAClearBonus() {
        let nibbling = ScoreRules.totalScore(eatenPoints: 100, percent: 40, timeRemaining: 10)
        XCTAssertEqual(nibbling, 100 + 30)
        let cleared = ScoreRules.totalScore(eatenPoints: 100, percent: 100, timeRemaining: 10)
        XCTAssertEqual(cleared, 100 + 30 + 750)
        let expired = ScoreRules.totalScore(eatenPoints: 100, percent: 100, timeRemaining: 0)
        XCTAssertEqual(expired, 100 + 750)
    }

    func testBiggerBitesAreWorthMore() {
        XCTAssertGreaterThan(
            ScoreRules.points(forRadius: PropKind.basket.radius),
            ScoreRules.points(forRadius: PropKind.grape.radius)
        )
    }

    func testSteerClampsSoLengthCannotSpeedHack() {
        let long = Vec2(x: 10, y: 0).clamped(maxLength: 1)
        XCTAssertEqual(long.length, 1, accuracy: 0.0001)
        XCTAssertEqual(Vec2.zero.clamped(maxLength: 1), .zero)
    }
}
