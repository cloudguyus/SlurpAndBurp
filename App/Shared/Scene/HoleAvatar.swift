import Foundation
import RealityKit
import SlurpAndBurpCore
import simd

/// The hungry hole: a dark mouth, a coral lip, and a face that wobbles, squints, and burps.
@MainActor
final class HoleAvatar {
    let root = Entity()
    private let disc = Entity()
    private let face = Entity()
    private let mouth = ModelEntity()
    private let tongue = ModelEntity()
    private let eyeL = ModelEntity()
    private let eyeR = ModelEntity()
    private let pupilL = ModelEntity()
    private let pupilR = ModelEntity()
    private let cheekL = ModelEntity()
    private let cheekR = ModelEntity()
    private var puffs: [ModelEntity] = []

    init() {
        let rim = ModelEntity(
            mesh: .generateCylinder(height: 0.05, radius: 1.18),
            materials: [Paint.unlit(0xFF6B6B)]
        )
        rim.position.y = 0.055
        let void = ModelEntity(
            mesh: .generateCylinder(height: 0.04, radius: 1),
            materials: [Paint.unlit(0x1B1028)]
        )
        void.position.y = 0.08
        let pit = ModelEntity(
            mesh: .generateCylinder(height: 0.02, radius: 0.72),
            materials: [Paint.unlit(0x09060F)]
        )
        pit.position.y = 0.1
        disc.addChild(rim)
        disc.addChild(void)
        disc.addChild(pit)

        mouth.model = ModelComponent(
            mesh: .generateSphere(radius: 0.18),
            materials: [Paint.unlit(0x140C1C)]
        )
        tongue.model = ModelComponent(
            mesh: .generateSphere(radius: 0.09),
            materials: [Paint.unlit(0xFF6B8A)]
        )
        eyeL.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0xFFF8F2)])
        eyeR.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0xFFF8F2)])
        pupilL.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0x24182E)])
        pupilR.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0x24182E)])
        cheekL.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0xFF8FA3)])
        cheekR.model = ModelComponent(mesh: .generateSphere(radius: 1), materials: [Paint.unlit(0xFF8FA3)])
        face.addChild(mouth)
        face.addChild(tongue)
        face.addChild(eyeL)
        face.addChild(eyeR)
        face.addChild(pupilL)
        face.addChild(pupilR)
        face.addChild(cheekL)
        face.addChild(cheekR)
        for _ in 0..<4 {
            let puff = ModelEntity(
                mesh: .generateSphere(radius: 0.2),
                materials: [Paint.unlit(0xF6F1FF)]
            )
            puff.isEnabled = false
            puffs.append(puff)
            face.addChild(puff)
        }
        root.addChild(disc)
        root.addChild(face)
    }

    func update(_ frame: HoleFrame) {
        let radius = frame.radius
        let speed: Float
        let amp: Float
        switch frame.mood {
        case .burping:
            speed = 13 + Float(frame.burp.rawValue) * 2
            amp = 0.05 + frame.burp.shake * 0.35
        case .slurping:
            speed = 11
            amp = 0.07
        case .moving:
            speed = 8
            amp = 0.045
        case .straining:
            speed = 16
            amp = 0.02
        case .idle:
            speed = 3.2
            amp = 0.025
        }
        let wobble = sin(frame.time * speed) * amp
        disc.position = [frame.position.x, 0, frame.position.y]
        disc.scale = [radius * (1 + wobble), 1, radius * (1 - wobble * 0.65)]

        face.position = [frame.position.x, 0.08 + sin(frame.time * 2.2) * 0.02, frame.position.y]
        face.orientation = simd_quatf(angle: frame.facing, axis: [0, 1, 0])

        let open = mouthOpen(frame)
        let mouthWidth = max(0.16, radius * (0.34 + open * 0.25))
        let mouthHeight = max(0.03, radius * (0.05 + open * 0.22))
        mouth.position = [0, 0.02, -radius * 0.78]
        mouth.scale = [mouthWidth, mouthHeight, radius * 0.16]
        tongue.isEnabled = open > 0.45
        tongue.position = [0, 0.01, -radius * 0.86]
        tongue.scale = [mouthWidth * 0.45, mouthHeight * 0.7, radius * 0.08]

        let blink = frame.time.truncatingRemainder(dividingBy: 3.6) > 3.38
        let eyeScale = 0.11 + min(radius, 3.5) * 0.045
        var squint: Float = blink ? 0.12 : 1
        if frame.mood == .burping {
            squint = 0.18 + 0.12 * sin(frame.burpProgress * .pi)
        } else if frame.mood == .straining {
            squint = 0.45
        }
        let eyeY = eyeScale * max(0.08, squint)
        eyeL.scale = [eyeScale, eyeY, eyeScale]
        eyeR.scale = [eyeScale * 0.92, eyeY, eyeScale * 0.92]
        eyeL.position = [-radius * 0.34, eyeScale * 0.15, -radius * 0.58]
        eyeR.position = [radius * 0.34, eyeScale * 0.28, -radius * 0.56]

        let pupil = eyeScale * 0.42
        let look: Float = frame.mood == .straining ? 0.35 : -0.15
        pupilL.scale = [pupil, pupil, pupil]
        pupilR.scale = [pupil, pupil, pupil]
        pupilL.position = eyeL.position + [0, 0, look * eyeScale - eyeScale * 0.55]
        pupilR.position = eyeR.position + [0, 0, look * eyeScale - eyeScale * 0.55]

        let cheek = eyeScale * (frame.mood == .burping ? 0.85 : 0.55)
        cheekL.scale = [cheek, cheek * 0.7, cheek]
        cheekR.scale = [cheek, cheek * 0.7, cheek]
        cheekL.position = [-radius * 0.5, -0.02, -radius * 0.7]
        cheekR.position = [radius * 0.5, -0.02, -radius * 0.7]

        let puffing = frame.mood == .burping
        for (index, puff) in puffs.enumerated() {
            puff.isEnabled = puffing
            guard puffing else { continue }
            let side: Float = index.isMultiple(of: 2) ? -1 : 1
            let rise = frame.burpProgress * (0.35 + Float(index) * 0.18) * (0.6 + Float(frame.burp.rawValue) * 0.35)
            let spread = radius * 0.25 * Float(index)
            puff.position = [side * spread, 0.15 + rise, -radius * 0.9 - Float(index) * 0.05]
            let size = sin(max(0, frame.burpProgress) * .pi) * (0.12 + Float(frame.burp.rawValue) * 0.06)
            puff.scale = [size, size * 0.8, size]
        }
    }

    private func mouthOpen(_ frame: HoleFrame) -> Float {
        switch frame.mood {
        case .idle:
            return 0.18 + 0.05 * sin(frame.time * 2)
        case .moving:
            return 0.32
        case .slurping:
            return 0.85
        case .straining:
            return 0.05
        case .burping:
            let swell = sin(frame.burpProgress * .pi)
            return 0.35 + swell * (0.4 + Float(frame.burp.rawValue) * 0.12)
        }
    }
}

struct HoleFrame {
    var position: Vec2
    var radius: Float
    var facing: Float
    var mood: HoleMood
    var burp: BurpTier
    var burpProgress: Float
    var time: Float
    var shake: Float
}
