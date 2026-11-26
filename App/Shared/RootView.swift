import SlurpAndBurpCore
import SwiftUI

struct RootView: View {
    @StateObject private var progress = ProgressModel()
    @State private var route: Route
    @State private var playSerial = 0

    init() {
        if LaunchConfig.screen == "results" {
            _route = State(initialValue: .resultsPreview)
        } else if LaunchConfig.previewBurp != nil {
            _route = State(initialValue: .play(LaunchConfig.level ?? .picnic, 0))
        } else if let level = LaunchConfig.level {
            _route = State(initialValue: .play(level, 0))
        } else {
            _route = State(initialValue: .title)
        }
    }

    var body: some View {
        Group {
            switch route {
            case .title:
                TitleView { route = .levels }
            case .levels:
                LevelSelectView(progress: progress, onBack: { route = .title }, onPlay: { id in
                    play(id)
                })
            case .play(let id, let token):
                GameScreen(
                    levelID: id,
                    progress: progress,
                    recordsProgress: LaunchConfig.previewBurp == nil && !LaunchConfig.freeze,
                    previewBurp: LaunchConfig.previewBurp,
                    onReplay: { play(id) },
                    onNext: { next in play(next) },
                    onExit: { route = .levels }
                )
                .id("\(id.rawValue)-\(token)")
            case .resultsPreview:
                ZStack {
                    Palette.cream.ignoresSafeArea()
                    ResultsView(
                        presentation: .previewCity,
                        onReplay: { route = .title },
                        onNext: nil,
                        onLevels: { route = .title }
                    )
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 840, minHeight: 620)
        #endif
    }

    private func play(_ id: LevelID) {
        playSerial += 1
        route = .play(id, playSerial)
    }
}

private enum Route: Equatable {
    case title
    case levels
    case play(LevelID, Int)
    case resultsPreview
}
