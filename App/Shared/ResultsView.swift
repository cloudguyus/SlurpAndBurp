import SlurpAndBurpCore
import SwiftUI

struct ResultsPresentation: Equatable {
    var levelName: String
    var percent: Double
    var stars: Int
    var burp: BurpTier
    var score: Int
    var best: Int?
    var isNewBest: Bool
    var eaten: Int
    var total: Int
    var caption: String
}

struct ResultsView: View {
    var presentation: ResultsPresentation
    var onReplay: () -> Void
    var onNext: (() -> Void)?
    var onLevels: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(presentation.levelName)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(Palette.ink.opacity(0.7))
                Text(presentation.burp.title)
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.ink)
                    .minimumScaleFactor(0.6)
                Text(presentation.burp.detail)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.75))
                Text("\(Int(presentation.percent.rounded()))%")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.coral)
                    .minimumScaleFactor(0.5)
                    .accessibilityLabel("\(Int(presentation.percent.rounded())) percent eaten")
                Text("eaten")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Palette.ink.opacity(0.65))
                    .padding(.top, -12)
                StarRow(stars: presentation.stars, size: 32)
                Text(presentation.caption)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundStyle(Palette.ink)
                Text("\(presentation.eaten) of \(presentation.total) bites")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.65))
                VStack(spacing: 4) {
                    Text("Score \(grouped(presentation.score))")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundStyle(Palette.ink)
                    if presentation.isNewBest {
                        Text("New best!")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundStyle(Palette.leaf)
                    } else if let best = presentation.best {
                        Text("Best \(grouped(best))")
                            .font(.system(.headline, design: .rounded))
                            .foregroundStyle(Palette.ink.opacity(0.6))
                    }
                }
                .padding(.top, 4)
                VStack(spacing: 10) {
                    JellyButton(title: "Slurp again", action: onReplay)
                    if let onNext {
                        JellyButton(title: "Next level", fill: Palette.ink, action: onNext)
                    }
                    Button("Level select", action: onLevels)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundStyle(Palette.ink.opacity(0.75))
                        .padding(.top, 4)
                }
                .padding(.top, 8)
            }
            .padding(24)
        }
        .frame(maxWidth: 460)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(20)
    }
}

extension ResultsPresentation {
    static var previewCity: ResultsPresentation {
        ResultsPresentation(
            levelName: "City Block",
            percent: 92,
            stars: 3,
            burp: .legendary,
            score: 4860,
            best: 4860,
            isNewBest: true,
            eaten: 34,
            total: 38,
            caption: ScoreRules.caption(stars: 3)
        )
    }

    static func live(session: GameSession, best: BestScore?, isNewBest: Bool) -> ResultsPresentation {
        let result = session.makeResult()
        return ResultsPresentation(
            levelName: session.level.name,
            percent: result.percent,
            stars: result.stars,
            burp: result.burp,
            score: result.score,
            best: best?.score,
            isNewBest: isNewBest,
            eaten: result.eatenCount,
            total: result.totalCount,
            caption: ScoreRules.caption(stars: result.stars)
        )
    }
}
