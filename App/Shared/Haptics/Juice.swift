import Foundation
import SlurpAndBurpCore
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum Juice {
    static func swallow(radius: Float) {
        #if os(iOS)
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        if radius > 1.5 {
            style = .heavy
        } else if radius > 0.7 {
            style = .medium
        } else {
            style = .light
        }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
        #endif
    }

    static func burp(_ tier: BurpTier) {
        #if os(iOS)
        switch tier {
        case .hic:
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        case .polite:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .hearty:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .rumbling, .legendary:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred(intensity: 1)
        }
        #elseif os(macOS)
        let performance: NSHapticFeedbackManager.FeedbackPattern = tier >= .rumbling ? .alignment : .generic
        NSHapticFeedbackManager.defaultPerformer.perform(performance, performanceTime: .now)
        #endif
    }
}
