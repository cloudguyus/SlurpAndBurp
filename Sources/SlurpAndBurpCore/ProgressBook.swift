import Foundation

public struct BestScore: Codable, Equatable, Sendable {
    public var score: Int
    public var percent: Double
    public var stars: Int

    public init(score: Int, percent: Double, stars: Int) {
        self.score = score
        self.percent = percent
        self.stars = stars
    }
}

public struct ProgressBook: Codable, Equatable, Sendable {
    public var bestByLevel: [LevelID: BestScore]

    public init(bestByLevel: [LevelID: BestScore] = [:]) {
        self.bestByLevel = bestByLevel
    }

    public func best(for level: LevelID) -> BestScore? {
        bestByLevel[level]
    }

    /// Keeps the higher score. A tie goes to the run that ate more of the level.
    @discardableResult
    public mutating func record(_ result: RoundResult) -> Bool {
        let incoming = BestScore(score: result.score, percent: result.percent, stars: result.stars)
        guard let current = bestByLevel[result.level] else {
            bestByLevel[result.level] = incoming
            return true
        }
        let betterScore = incoming.score > current.score
        let betterPlate = incoming.score == current.score && incoming.percent > current.percent
        guard betterScore || betterPlate else { return false }
        bestByLevel[result.level] = incoming
        return true
    }
}

public enum ProgressStore {
    public static let storageKey = "slurpAndBurp.progress.v1"

    public static func load(from defaults: UserDefaults = .standard, key: String = storageKey) -> ProgressBook {
        guard let data = defaults.data(forKey: key) else { return ProgressBook() }
        guard let book = try? JSONDecoder().decode(ProgressBook.self, from: data) else {
            return ProgressBook()
        }
        return book
    }

    public static func save(_ book: ProgressBook, to defaults: UserDefaults = .standard, key: String = storageKey) {
        guard let data = try? JSONEncoder().encode(book) else { return }
        defaults.set(data, forKey: key)
    }
}
