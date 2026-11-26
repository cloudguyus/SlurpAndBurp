import SwiftUI

struct TitleView: View {
    var onPlay: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                HoleBadge()
                    .frame(width: 180, height: 180)
                    .padding(.top, 24)
                VStack(spacing: 6) {
                    Text("Slurp & Burp")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundStyle(Palette.ink)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("A hungry hole with manners.")
                        .font(.system(.title3, design: .rounded))
                        .foregroundStyle(Palette.ink.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                VStack(alignment: .leading, spacing: 8) {
                    controlLine("Drag to steer. Smaller things tip in and the hole grows.")
                    #if os(macOS)
                    controlLine("WASD or the arrow keys work too. The window can go full screen.")
                    #else
                    controlLine("Turn the phone either way. Haptics rumble when it burps.")
                    #endif
                }
                .padding(16)
                .frame(maxWidth: 460, alignment: .leading)
                .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                JellyButton(title: "Play", action: onPlay)
                    .frame(maxWidth: 460)
                Text("Best scores stay on this device.")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Palette.ink.opacity(0.55))
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
        }
        .background(titleBackground)
    }

    private func controlLine(_ text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .rounded))
            .foregroundStyle(Palette.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var titleBackground: some View {
        LinearGradient(
            colors: [Palette.cream, Color(red: 1, green: 0.78, blue: 0.62)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

private struct HoleBadge: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let wobble = sin(time * 3.2)
            ZStack {
                Circle()
                    .fill(Palette.coral)
                    .scaleEffect(x: 1 + wobble * 0.04, y: 1 - wobble * 0.03)
                Circle()
                    .fill(Color(red: 0.1, green: 0.06, blue: 0.16))
                    .padding(16)
                    .scaleEffect(x: 1 - wobble * 0.03, y: 1 + wobble * 0.02)
                HStack(spacing: 22) {
                    eye
                    eye
                }
                .offset(y: -8)
                Capsule()
                    .fill(Color(red: 0.1, green: 0.06, blue: 0.16))
                    .frame(width: 36 + wobble * 4, height: 10 + (sin(time * 4) + 1) * 4)
                    .offset(y: 36)
            }
        }
        .accessibilityHidden(true)
    }

    private var eye: some View {
        ZStack {
            Circle().fill(.white).frame(width: 28, height: 28)
            Circle().fill(Palette.ink).frame(width: 12, height: 12).offset(y: 2)
        }
    }
}
