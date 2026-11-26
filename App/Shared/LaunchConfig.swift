import Foundation
import SlurpAndBurpCore

enum LaunchConfig {
    static var level: LevelID? {
        argument(after: "--level").flatMap(LevelID.init(rawValue:))
    }

    static var screen: String? {
        argument(after: "--screen")
    }

    static var freeze: Bool {
        ProcessInfo.processInfo.arguments.contains("--freeze")
    }

    static var burpPercent: Double {
        Double(argument(after: "--percent") ?? "") ?? 96
    }

    static var previewBurp: Double? {
        screen == "burp" ? burpPercent : nil
    }

    private static func argument(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}
