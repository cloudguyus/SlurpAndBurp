import RealityKit
import SlurpAndBurpCore
import SwiftUI
#if os(iOS)
import UIKit
#endif

struct GameScreen: View {
    @StateObject private var model: GameModel
    @Environment(\.scenePhase) private var scenePhase
    var onReplay: () -> Void
    var onNext: ((LevelID) -> Void)?
    var onExit: () -> Void

    init(
        levelID: LevelID,
        progress: ProgressModel,
        recordsProgress: Bool,
        previewBurp: Double?,
        onReplay: @escaping () -> Void,
        onNext: ((LevelID) -> Void)?,
        onExit: @escaping () -> Void
    ) {
        _model = StateObject(
            wrappedValue: GameModel(
                level: LevelCatalog.level(levelID),
                progress: progress,
                recordsProgress: recordsProgress,
                previewBurp: previewBurp
            )
        )
        self.onReplay = onReplay
        self.onNext = onNext
        self.onExit = onExit
    }

    var body: some View {
        let snapshot = model.snapshot
        let theme = LevelTheme.palette(model.session.level.id)
        ZStack {
            theme.sky.ignoresSafeArea()
            SceneHost(scene: model.scene)
                .ignoresSafeArea()
                .steerPad(
                    enabled: snapshot.phase == .playing && !model.userPaused,
                    onSteer: { model.setSteer($0) },
                    onEscape: { model.togglePause() }
                )
            if snapshot.phase == .playing || snapshot.phase == .burping || showHints(snapshot) {
                VStack(spacing: 10) {
                    if snapshot.phase == .playing || snapshot.phase == .burping {
                        HUDView(snapshot: snapshot, paused: model.userPaused, onPause: { model.togglePause() })
                    }
                    Spacer()
                        .allowsHitTesting(false)
                    if showHints(snapshot) {
                        hintCard
                    }
                }
                .padding(playfieldPadding)
            }
            if snapshot.phase == .burping {
                burpBanner(snapshot)
            }
            if model.userPaused, snapshot.phase == .playing {
                pauseCard
            }
            if snapshot.phase == .results {
                ResultsView(
                    presentation: ResultsPresentation.live(
                        session: model.session,
                        best: model.savedBest(),
                        isNewBest: model.isNewBest
                    ),
                    onReplay: onReplay,
                    onNext: model.session.level.id.next.map { next in { onNext?(next) } },
                    onLevels: onExit
                )
                .padding(playfieldPadding)
            }
        }
        .ignoresSafeArea()
        .offset(shakeOffset)
        .onReceive(Timer.publish(every: 1.0 / 60.0, tolerance: 1.0 / 120.0, on: .main, in: .common).autoconnect()) { date in
            model.advance(to: date)
        }
        .onChange(of: scenePhase) { _, phase in
            model.setSystemPaused(phase != .active)
        }
    }

    private var shakeOffset: CGSize {
        let amount = CGFloat(model.shake) * 48
        guard amount > 0.2 else { return .zero }
        let time = Date().timeIntervalSinceReferenceDate
        return CGSize(width: CGFloat(sin(time * 53)) * amount, height: CGFloat(cos(time * 41)) * amount * 0.6)
    }

    private func showHints(_ snapshot: RoundSnapshot) -> Bool {
        guard snapshot.phase == .playing, snapshot.eatenCount == 0 else { return false }
        let elapsed = model.session.level.duration - snapshot.timeRemaining
        return elapsed < 12
    }

    /// Distance from the physical screen edges to the island, home indicator, and landscape sides.
    private var playfieldPadding: EdgeInsets {
        #if os(iOS)
        let raw = Self.iphoneSafeArea()
        return EdgeInsets(
            top: raw.top + 8,
            leading: raw.left + 8,
            bottom: raw.bottom + 12,
            trailing: raw.right + 8
        )
        #else
        return EdgeInsets(top: 12, leading: 16, bottom: 16, trailing: 16)
        #endif
    }

    #if os(iOS)
    private static func iphoneSafeArea() -> UIEdgeInsets {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let window = scenes.flatMap(\.windows).first { $0.isKeyWindow } ?? scenes.first?.windows.first
        return window?.safeAreaInsets ?? UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0)
    }
    #endif

    private var hintCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.session.level.hints, id: \.self) { hint in
                Text(hint)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(Palette.ink)
            }
        }
        .padding(16)
        .frame(maxWidth: 420, alignment: .leading)
        .background(.white.opacity(0.92), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .frame(maxWidth: .infinity)
        .allowsHitTesting(false)
    }

    private func burpBanner(_ snapshot: RoundSnapshot) -> some View {
        VStack(spacing: 6) {
            Spacer()
            Text(snapshot.burp.title)
                .font(.system(size: 40 + CGFloat(snapshot.burp.rawValue) * 6, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
                .scaleEffect(0.85 + snapshot.burpProgress * 0.3)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(snapshot.burp.detail)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(.horizontal, 24)
        .allowsHitTesting(false)
    }

    private var pauseCard: some View {
        ZStack {
            Color.black.opacity(0.28).ignoresSafeArea()
            VStack(spacing: 14) {
                Text("Paused")
                    .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                    .foregroundStyle(Palette.ink)
                JellyButton(title: "Resume", action: { model.togglePause() })
                JellyButton(title: "Quit", fill: Palette.ink, action: onExit)
            }
            .padding(24)
            .frame(maxWidth: 360)
            .background(Palette.card, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(24)
        }
    }
}

private struct SceneHost: View {
    let scene: GameSceneController

    var body: some View {
        RealityView { content in
            scene.install(&content)
        }
    }
}
