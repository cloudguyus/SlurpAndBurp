import RealityKit
import SlurpAndBurpCore
import simd

/// Owns the RealityKit world for one round and moves it to match the simulation.
@MainActor
final class GameSceneController {
    let level: LevelDefinition
    private let world = Entity()
    private let camera = PerspectiveCamera()
    private let hole = HoleAvatar()
    private var props: [Int: Entity] = [:]
    private var installed = false

    init(level: LevelDefinition) {
        self.level = level
    }

    func install(_ content: inout RealityViewCameraContent) {
        guard !installed else { return }
        installed = true
        content.camera = .virtual
        camera.camera = PerspectiveCameraComponent(near: 0.04, far: 400, fieldOfViewInDegrees: 70)
        world.addChild(Scenery.build(level: level))
        for spawn in level.props {
            let entity = PropFactory.make(spawn.kind)
            entity.scale = SIMD3(repeating: spawn.radius)
            entity.position = [spawn.position.x, 0, spawn.position.y]
            entity.orientation = simd_quatf(angle: spawn.yaw, axis: [0, 1, 0])
            props[spawn.id] = entity
            world.addChild(entity)
        }
        world.addChild(hole.root)
        content.add(world)
        content.add(camera)
        camera.look(at: .zero, from: [0, 8, 5.5], relativeTo: nil)
    }

    func apply(session: GameSession, time: Float, shake: Float) {
        guard installed else { return }
        hole.update(
            HoleFrame(
                position: session.holePosition,
                radius: session.holeRadius,
                facing: session.holeFacing,
                mood: session.currentMood(),
                burp: session.burp,
                burpProgress: Float(session.burpProgress),
                time: time,
                shake: shake
            )
        )
        let holePosition = session.holePosition
        for prop in session.props {
            guard let entity = props[prop.id] else { continue }
            entity.isEnabled = !prop.consumed
            guard !prop.consumed else { continue }
            let sink = prop.slurp
            let scale = prop.radius * max(0.05, 1 - sink * 0.92)
            entity.scale = SIMD3(repeating: scale)
            entity.position = [prop.position.x, -sink * 0.9, prop.position.y]
            let yaw = simd_quatf(angle: prop.yaw, axis: [0, 1, 0])
            if sink > 0.001 {
                let axis = SIMD3<Float>(
                    -(holePosition.y - prop.position.y),
                    0,
                    holePosition.x - prop.position.x
                )
                let length = simd_length(axis)
                if length > 0.0001 {
                    let tilt = simd_quatf(angle: sink * 1.2, axis: axis / length)
                    entity.orientation = tilt * yaw
                } else {
                    entity.orientation = yaw
                }
            } else {
                entity.orientation = yaw
            }
        }
        aimCamera(session: session, time: time, shake: shake)
    }

    private func aimCamera(session: GameSession, time: Float, shake: Float) {
        let span = 6.4 + session.holeRadius * 2.45
        var eye = SIMD3<Float>(
            session.holePosition.x + session.steer.x * 0.35,
            span * 1.08,
            session.holePosition.y + span * 0.62
        )
        let target = SIMD3<Float>(
            session.holePosition.x + session.steer.x * 0.55,
            0,
            session.holePosition.y + session.steer.y * 0.55
        )
        if shake > 0.001 {
            eye.x += sin(time * 53) * shake
            eye.y += cos(time * 41) * shake * 0.3
            eye.z += sin(time * 37 + 1.2) * shake
        }
        camera.look(at: target, from: eye, relativeTo: nil)
    }
}
