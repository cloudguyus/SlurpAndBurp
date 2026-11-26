import SlurpAndBurpCore
import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Touch drag, click drag, and (on the Mac) WASD plus the arrow keys.
struct SteerPad: ViewModifier {
    var enabled: Bool
    var onSteer: (Vec2) -> Void
    var onEscape: () -> Void

    @State private var drag = Vec2.zero
    @State private var dragging = false
    @State private var keys = Vec2.zero

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let vector = Self.vector(width: value.translation.width, height: value.translation.height)
                        dragging = true
                        drag = vector
                        emit(keys: keys, dragging: true, drag: vector)
                    }
                    .onEnded { _ in
                        dragging = false
                        drag = .zero
                        emit(keys: keys, dragging: false, drag: .zero)
                    }
            )
            .background(keyCatcher)
            .onChange(of: enabled) { _, _ in
                emit(keys: keys, dragging: dragging, drag: drag)
            }
    }

    private func emit(keys: Vec2, dragging: Bool, drag: Vec2) {
        guard enabled else {
            onSteer(.zero)
            return
        }
        if keys.length > 0.01 {
            onSteer(keys)
        } else if dragging {
            onSteer(drag)
        } else {
            onSteer(.zero)
        }
    }

    private static func vector(width: CGFloat, height: CGFloat) -> Vec2 {
        let dx = Float(width)
        let dy = Float(height)
        let length = (dx * dx + dy * dy).squareRoot()
        guard length > 2 else { return .zero }
        let magnitude = min(1, length / 90)
        return Vec2(x: dx / length * magnitude, y: dy / length * magnitude)
    }

    @ViewBuilder private var keyCatcher: some View {
        #if os(macOS)
        MacKeyCatcher(
            onSteer: { vector in
                keys = vector
                emit(keys: vector, dragging: dragging, drag: drag)
            },
            onEscape: onEscape
        )
        #else
        Color.clear.frame(width: 0, height: 0)
        #endif
    }
}

#if os(macOS)
private struct MacKeyCatcher: NSViewRepresentable {
    var onSteer: (Vec2) -> Void
    var onEscape: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSteer: onSteer, onEscape: onEscape)
    }

    func makeNSView(context: Context) -> NSView {
        context.coordinator.start()
        return NSView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onSteer = onSteer
        context.coordinator.onEscape = onEscape
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        coordinator.stop()
    }

    final class Coordinator {
        var onSteer: (Vec2) -> Void
        var onEscape: () -> Void
        private var monitor: Any?
        private var observers: [NSObjectProtocol] = []
        private var held: Set<UInt16> = []

        init(onSteer: @escaping (Vec2) -> Void, onEscape: @escaping () -> Void) {
            self.onSteer = onSteer
            self.onEscape = onEscape
        }

        func start() {
            guard monitor == nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { [weak self] event in
                guard let self else { return event }
                let code = event.keyCode
                let movement: Set<UInt16> = [0, 1, 2, 13, 123, 124, 125, 126]
                if code == 53, event.type == .keyDown, !event.isARepeat {
                    self.onEscape()
                    return nil
                }
                guard movement.contains(code) else { return event }
                if event.type == .keyDown {
                    self.held.insert(code)
                } else {
                    self.held.remove(code)
                }
                self.onSteer(Self.vector(self.held))
                return nil
            }
            let names = [NSWindow.didResignKeyNotification, NSApplication.didResignActiveNotification]
            for name in names {
                let token = NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                    self?.releaseKeys()
                }
                observers.append(token)
            }
        }

        func releaseKeys() {
            guard !held.isEmpty else { return }
            held.removeAll()
            onSteer(.zero)
        }

        func stop() {
            releaseKeys()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            for token in observers {
                NotificationCenter.default.removeObserver(token)
            }
            observers.removeAll()
        }

        private static func vector(_ held: Set<UInt16>) -> Vec2 {
            var x: Float = 0
            var y: Float = 0
            if held.contains(0) || held.contains(123) { x -= 1 }
            if held.contains(2) || held.contains(124) { x += 1 }
            if held.contains(13) || held.contains(126) { y -= 1 }
            if held.contains(1) || held.contains(125) { y += 1 }
            return Vec2(x: x, y: y).clamped(maxLength: 1)
        }
    }
}
#endif

extension View {
    func steerPad(enabled: Bool, onSteer: @escaping (Vec2) -> Void, onEscape: @escaping () -> Void) -> some View {
        modifier(SteerPad(enabled: enabled, onSteer: onSteer, onEscape: onEscape))
    }
}
