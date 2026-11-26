import SlurpAndBurpCore
import SwiftUI

struct HUDView: View {
    var snapshot: RoundSnapshot
    var paused: Bool
    var onPause: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                timer
                Spacer(minLength: 8)
                score
                if snapshot.phase == .playing {
                    Button(action: onPause) {
                        Image(systemName: paused ? "play.fill" : "pause.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.9), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(paused ? "Resume" : "Pause")
                }
            }
            HStack {
                label(snapshot.appetiteName, system: "circle.fill")
                Spacer()
                Text("\(Int(snapshot.percentEaten.rounded()))% eaten")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("\(snapshot.eatenCount)/\(snapshot.totalCount)")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.horizontal, 4)
            Spacer()
                .allowsHitTesting(false)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var timer: some View {
        Text(clock(snapshot.timeRemaining))
            .font(.system(size: 28, weight: .heavy, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
            .accessibilityLabel("Time remaining \(clock(snapshot.timeRemaining))")
    }

    private var score: some View {
        Text(grouped(snapshot.score))
            .font(.system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.9), in: Capsule())
            .accessibilityLabel("Score \(snapshot.score)")
    }

    private func label(_ text: String, system: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: system)
            Text(text)
        }
        .font(.system(.subheadline, design: .rounded).weight(.bold))
        .foregroundStyle(.white)
    }
}
