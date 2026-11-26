import Foundation
import RealityKit
import SlurpAndBurpCore

@MainActor
enum Scenery {
    static func build(level: LevelDefinition) -> Entity {
        let root = Entity()
        let theme = LevelTheme.palette(level.id)
        let ground = ModelEntity(
            mesh: .generateCylinder(height: 2, radius: level.arenaRadius + 24),
            materials: [Paint.unlit(theme.ground)]
        )
        ground.position = [0, -1, 0]
        root.addChild(ground)

        let lip = ModelEntity(
            mesh: .generateCylinder(height: 0.04, radius: level.arenaRadius + 0.55),
            materials: [Paint.unlit(theme.trim)]
        )
        lip.position = [0, 0.01, 0]
        root.addChild(lip)

        let inner = ModelEntity(
            mesh: .generateCylinder(height: 0.04, radius: level.arenaRadius),
            materials: [Paint.unlit(theme.ground)]
        )
        inner.position = [0, 0.02, 0]
        root.addChild(inner)

        switch level.id {
        case .picnic:
            addBlanket(to: root)
        case .kitchen:
            addRug(to: root)
        case .backyard:
            addPatio(to: root)
        case .city:
            addRoads(to: root, arena: level.arenaRadius)
        }
        addPosts(to: root, radius: level.arenaRadius + 1.6, hex: theme.post)
        return root
    }

    private static func addBlanket(to root: Entity) {
        let cell: Float = 0.72
        let count = 8
        let origin = -cell * Float(count - 1) / 2
        for row in 0..<count {
            for column in 0..<count {
                let light = (row + column).isMultiple(of: 2)
                let tile = ModelEntity(
                    mesh: .generateBox(size: [cell * 0.96, 0.02, cell * 0.96], cornerRadius: 0),
                    materials: [Paint.unlit(light ? 0xF7F1E1 : 0xE25B5B)]
                )
                tile.position = [origin + Float(column) * cell, 0.035, origin + Float(row) * cell]
                root.addChild(tile)
            }
        }
    }

    private static func addRug(to root: Entity) {
        let rug = ModelEntity(
            mesh: .generateBox(size: [6.5, 0.02, 4.2], cornerRadius: 0),
            materials: [Paint.unlit(0xD96C4A)]
        )
        rug.position = [0, 0.03, 0]
        root.addChild(rug)
        let inset = ModelEntity(
            mesh: .generateBox(size: [5.6, 0.02, 3.3], cornerRadius: 0),
            materials: [Paint.unlit(0xF3D2A4)]
        )
        inset.position = [0, 0.04, 0]
        root.addChild(inset)
    }

    private static func addPatio(to root: Entity) {
        let patio = ModelEntity(
            mesh: .generateCylinder(height: 0.04, radius: 3.4),
            materials: [Paint.unlit(0xE2C29A)]
        )
        patio.position = [3.2, 0.035, 2.4]
        root.addChild(patio)
    }

    private static func addRoads(to root: Entity, arena: Float) {
        let length = arena * 1.7
        let east = ModelEntity(
            mesh: .generateBox(size: [length, 0.02, 2.2], cornerRadius: 0),
            materials: [Paint.unlit(0x6E7684)]
        )
        east.position = [0, 0.03, 0]
        root.addChild(east)
        let north = ModelEntity(
            mesh: .generateBox(size: [2.2, 0.02, length], cornerRadius: 0),
            materials: [Paint.unlit(0x6E7684)]
        )
        north.position = [0, 0.04, 0]
        root.addChild(north)
    }

    private static func addPosts(to root: Entity, radius: Float, hex: UInt32) {
        let count = 18
        for index in 0..<count {
            let angle = Float(index) / Float(count) * Float.pi * 2
            let post = ModelEntity(
                mesh: .generateCylinder(height: 0.7, radius: 0.08),
                materials: [Paint.unlit(hex)]
            )
            post.position = [cos(angle) * radius, 0.4, sin(angle) * radius]
            root.addChild(post)
        }
    }
}
