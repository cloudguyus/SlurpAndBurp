import Foundation
import SlurpAndBurpCore

@MainActor
final class ProgressModel: ObservableObject {
    @Published private(set) var book: ProgressBook

    init() {
        book = ProgressStore.load()
    }

    @discardableResult
    func record(_ result: RoundResult) -> Bool {
        let isBest = book.record(result)
        ProgressStore.save(book)
        return isBest
    }

    func best(for level: LevelID) -> BestScore? {
        book.best(for: level)
    }
}
