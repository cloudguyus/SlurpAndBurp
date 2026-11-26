import SlurpAndBurpCore
import SwiftUI

enum Palette {
    static let ink = Color(red: 0.17, green: 0.12, blue: 0.27)
    static let cream = Color(red: 1.0, green: 0.96, blue: 0.90)
    static let coral = Color(red: 1.0, green: 0.38, blue: 0.38)
    static let leaf = Color(red: 0.24, green: 0.62, blue: 0.38)
    static let sun = Color(red: 1.0, green: 0.78, blue: 0.28)
    static let sky = Color(red: 0.53, green: 0.82, blue: 0.96)
    static let card = Color.white.opacity(0.92)
}

struct LevelTheme {
    var ground: UInt32
    var trim: UInt32
    var post: UInt32
    var sky: Color
    var accent: Color
    var symbol: String

    static func palette(_ id: LevelID) -> LevelTheme {
        switch id {
        case .picnic:
            return LevelTheme(ground: 0x7BC96F, trim: 0xF2D2A9, post: 0xE7A15A, sky: Color(red: 0.62, green: 0.86, blue: 0.98), accent: Palette.leaf, symbol: "leaf.fill")
        case .kitchen:
            return LevelTheme(ground: 0xE7D3B0, trim: 0xC47A4A, post: 0x8C6239, sky: Color(red: 0.98, green: 0.86, blue: 0.72), accent: Color(red: 0.86, green: 0.45, blue: 0.28), symbol: "fork.knife")
        case .backyard:
            return LevelTheme(ground: 0x6FBF73, trim: 0xC4A574, post: 0x6B8F71, sky: Color(red: 0.55, green: 0.84, blue: 0.95), accent: Color(red: 0.20, green: 0.55, blue: 0.36), symbol: "tree.fill")
        case .city:
            return LevelTheme(ground: 0xB7C0CE, trim: 0x8B93A3, post: 0x5E6675, sky: Color(red: 0.62, green: 0.74, blue: 0.88), accent: Color(red: 0.29, green: 0.45, blue: 0.82), symbol: "building.2.fill")
        }
    }
}

struct JellyButton: View {
    var title: String
    var fill: Color = Palette.coral
    var ink: Color = .white
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(fill, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct StarRow: View {
    var stars: Int
    var total: Int = 3
    var size: CGFloat = 22

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Image(systemName: index < stars ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(index < stars ? Palette.sun : Palette.ink.opacity(0.22))
                    .accessibilityLabel(index < stars ? "Filled star" : "Empty star")
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(stars) of \(total) stars")
    }
}

func clock(_ time: TimeInterval) -> String {
    let remaining = max(0, Int(time.rounded(.up)))
    return String(format: "%d:%02d", remaining / 60, remaining % 60)
}

func grouped(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}
