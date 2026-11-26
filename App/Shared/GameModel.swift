import Combine
import Foundation
import SlurpAndBurpCore

@MainActor
final class GameModel: ObservableObject {
    let session: GameSession
    let scene: GameSceneController
    let synth = SoundSynth()
    private let progress: ProgressModel
    private let recordsProgress: Bool

    @Published private(set) var snapshot: RoundSnapshot
    @Published private(set) var shake: Float = 0
    @Published private(set) var isNewBest = false
    @Published private(set) var userPaused = false

    private var smoothedShake: Float = 0
    private var renderTime: Float = 0
    private var lastTick: Date?
    private var hudAccumulator: TimeInterval = 0
    private var recorded = false
    private var playedBurp = false
    private var systemPaused = false

    init(level: LevelDefinition, progress: ProgressModel, recordsProgress: Bool = true, previewBurp percent: Double? = nil) {
        self.progress = progress
        self.recordsProgress = recordsProgress
        session = GameSession(level: level)
        scene = GameSceneController(level: level)
        if let percent {
            session.previewBurp(percent: percent)
        }
        snapshot = session.snapshot()
        if LaunchConfig.freeze {
            userPaused = true
            session.isPaused = true
        }
    }

    func setSteer(_ steer: Vec2) {
        session.steer = steer
    }

    func togglePause() {
        guard session.phase == .playing else { return }
        userPaused.toggle()
        syncPause()
    }

    func savedBest() -> BestScore? {
        progress.best(for: session.level.id)
    }

    func setSystemPaused(_ paused: Bool) {
        systemPaused = paused
        syncPause()
    }

    func advance(to date: Date) {
        let dt: TimeInterval
        if let lastTick {
            dt = min(0.1, max(0, date.timeIntervalSince(lastTick)))
        } else {
            dt = 1.0 / 60.0
        }
        self.lastTick = date
        renderTime += Float(dt)

        let events = session.tick(deltaTime: dt)
        if session.phase == .burping, !playedBurp, !session.isPaused {
            playedBurp = true
            synth.playBurp(session.burp)
            Juice.burp(session.burp)
        }
        if !events.isEmpty {
            synth.playSlurp()
            let biggest = events.map(\.radius).max() ?? 0
            Juice.swallow(radius: biggest)
            if biggest > 0.9 {
                smoothedShake = max(smoothedShake, min(0.12, biggest * 0.035))
            }
        }
        if session.phase == .burping {
            let envelope = sin(session.burpProgress * .pi)
            smoothedShake = session.burp.shake * Float(max(0, envelope))
        } else if session.phase == .playing {
            smoothedShake *= 0.86
        }

        scene.apply(session: session, time: renderTime, shake: smoothedShake)

        hudAccumulator += dt
        let phaseChanged = snapshot.phase != session.phase
        let shakeChanged = abs(smoothedShake - shake) > 0.004
        if phaseChanged || hudAccumulator >= 0.1 || session.phase != .playing || shakeChanged {
            hudAccumulator = 0
            snapshot = session.snapshot()
            shake = smoothedShake
        }
        if session.phase == .results, !recorded {
            recorded = true
            snapshot = session.snapshot()
            if recordsProgress {
                isNewBest = progress.record(session.makeResult())
            }
        }
    }

    private func syncPause() {
        session.isPaused = userPaused || systemPaused
    }
}
