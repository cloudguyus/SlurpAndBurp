import SlurpAndBurpCore
import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var progress: ProgressModel
    var onBack: () -> Void
    var onPlay: (LevelID) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.8), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")
                    Text("Pick a level")
                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                }
                .padding(.top, 8)
                ForEach(LevelCatalog.all, id: \.id) { level in
                    levelCard(level)
                }
            }
            .padding(20)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Palette.cream.ignoresSafeArea())
    }

    private func levelCard(_ level: LevelDefinition) -> some View {
        let theme = LevelTheme.palette(level.id)
        let best = progress.best(for: level.id)
        return Button {
            onPlay(level.id)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: theme.symbol)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.name)
                        .font(.system(.title3, design: .rounded).weight(.heavy))
                        .foregroundStyle(Palette.ink)
                    Text(level.blurb)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(Palette.ink.opacity(0.7))
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 8) {
                        StarRow(stars: best?.stars ?? 0, size: 14)
                        Text(best.map { "Best \(grouped($0.score))" } ?? "No bites yet")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .foregroundStyle(Palette.ink.opacity(0.6))
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Palette.ink.opacity(0.4))
            }
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(level.name). \(level.blurb)")
    }
}
