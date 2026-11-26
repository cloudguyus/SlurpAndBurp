import RealityKit
import SlurpAndBurpCore
import simd

/// Original low-poly snacks and furniture, built from boxes, spheres, cylinders, and cones.
@MainActor
enum PropFactory {
    static func make(_ kind: PropKind) -> Entity {
        let root = Entity()
        root.name = kind.rawValue
        for bit in bits(for: kind) {
            root.addChild(Meshes.entity(bit))
        }
        return root
    }

    private static func bits(for kind: PropKind) -> [Bit] {
        switch kind {
        case .grape:
            return [
                sphere(0.82, [0, 0.86, 0], 0x7B3FE4),
                sphere(0.22, [0.18, 1.55, 0], 0x3FA34D),
            ]
        case .cookie:
            return [
                cyl(0.95, 0.28, [0, 0.2, 0], 0xE0A15A),
                sphere(0.12, [0.35, 0.38, 0.2], 0x5A3828),
                sphere(0.1, [-0.3, 0.38, 0.25], 0x5A3828),
                sphere(0.11, [0.05, 0.38, -0.35], 0x5A3828),
                sphere(0.09, [-0.2, 0.38, -0.15], 0x5A3828),
            ]
        case .napkin:
            return [box([1.7, 0.06, 1.45], [0, 0.06, 0], 0xF7F1E1, spin: 0.4, axis: [0, 1, 0])]
        case .plate:
            return [
                cyl(1.0, 0.08, [0, 0.08, 0], 0xF4F7FB),
                cyl(0.62, 0.05, [0, 0.13, 0], 0xE4ECF4),
            ]
        case .cupcake:
            return [
                cyl(0.72, 0.5, [0, 0.3, 0], 0xF2A3C7),
                sphere(0.62, [0, 0.72, 0], 0xFF6FA5),
                sphere(0.16, [0, 1.28, 0], 0xE23D3D),
            ]
        case .sandwich:
            return [
                box([1.55, 0.18, 1.15], [0, 0.18, 0], 0xF0C27A),
                box([1.3, 0.08, 0.95], [0, 0.32, 0], 0x7ED36A),
                box([1.2, 0.1, 0.85], [0, 0.42, 0], 0xE36B4A),
                box([1.55, 0.18, 1.15], [0, 0.58, 0], 0xF6D59A),
            ]
        case .thermos:
            return [
                cyl(0.42, 1.25, [0, 0.7, 0], 0xE2534A),
                cyl(0.36, 0.28, [0, 1.42, 0], 0xF4F1EA),
                cyl(0.46, 0.12, [0, 0.85, 0], 0xF4D35E),
            ]
        case .cooler:
            return [
                box([1.5, 0.9, 1.05], [0, 0.5, 0], 0x3DB7C9),
                box([1.58, 0.16, 1.12], [0, 1.02, 0], 0xF7FBFC),
                box([0.46, 0.1, 0.12], [0, 1.18, 0], 0xE7EEF2),
            ]
        case .basket:
            return [
                box([1.45, 0.7, 1.05], [0, 0.4, 0], 0xC68642),
                box([1.55, 0.12, 1.15], [0, 0.8, 0], 0xA86B32),
                cyl(0.06, 0.7, [-0.55, 1.1, 0], 0x8C5A2B),
                cyl(0.06, 0.7, [0.55, 1.1, 0], 0x8C5A2B),
                box([1.2, 0.08, 0.08], [0, 1.46, 0], 0x8C5A2B),
            ]
        case .spoon:
            return [
                box([0.16, 0.08, 1.35], [0, 0.08, -0.15], 0xD5DDEA),
                sphere(0.38, [0, 0.12, 0.78], 0xF7F8FC),
            ]
        case .spatula:
            return [
                box([0.14, 0.06, 1.2], [0, 0.08, -0.2], 0xF2C14E),
                box([0.72, 0.06, 0.55], [0, 0.1, 0.75], 0xF28B6A),
            ]
        case .mug:
            return [
                cyl(0.55, 0.72, [0, 0.42, 0], 0xF6F1E7),
                cyl(0.4, 0.16, [0, 0.74, 0], 0x6B4226),
                box([0.12, 0.38, 0.14], [0.62, 0.42, 0], 0xE7D7C3),
            ]
        case .kettle:
            return [
                sphere(0.58, [0, 0.58, 0], 0xF25C54),
                cone(0.16, 0.5, [0.62, 0.7, 0], 0xF25C54, spin: .pi / 2, axis: [0, 0, 1]),
                cyl(0.22, 0.12, [0, 1.12, 0], 0x2E2A32),
                box([0.1, 0.45, 0.12], [-0.62, 0.7, 0], 0x2E2A32),
            ]
        case .toaster:
            return [
                box([1.25, 0.7, 0.8], [0, 0.42, 0], 0xF3F4F7),
                box([0.28, 0.08, 0.4], [-0.28, 0.8, 0], 0x2B2E38),
                box([0.28, 0.08, 0.4], [0.28, 0.8, 0], 0x2B2E38),
                box([0.08, 0.28, 0.08], [0.72, 0.55, 0], 0xE23B3B),
            ]
        case .pot:
            return [
                cyl(0.78, 0.55, [0, 0.36, 0], 0xC5CCD8),
                cyl(0.7, 0.1, [0, 0.68, 0], 0x8E97A8),
                sphere(0.1, [0, 0.8, 0], 0xF4D35E),
                box([0.28, 0.1, 0.12], [-0.95, 0.45, 0], 0x8E97A8),
                box([0.28, 0.1, 0.12], [0.95, 0.45, 0], 0x8E97A8),
            ]
        case .chair:
            return [
                box([1.0, 0.12, 1.0], [0, 0.58, 0], 0xE07A5F),
                box([1.0, 0.7, 0.1], [0, 0.98, -0.45], 0xE07A5F),
                cyl(0.07, 0.55, [-0.38, 0.28, -0.38], 0x6B4F3A),
                cyl(0.07, 0.55, [0.38, 0.28, -0.38], 0x6B4F3A),
                cyl(0.07, 0.55, [-0.38, 0.28, 0.38], 0x6B4F3A),
                cyl(0.07, 0.55, [0.38, 0.28, 0.38], 0x6B4F3A),
            ]
        case .table:
            return [
                box([2.0, 0.12, 1.25], [0, 0.78, 0], 0xE6B15A),
                cyl(0.08, 0.74, [-0.8, 0.38, -0.45], 0x8C6239),
                cyl(0.08, 0.74, [0.8, 0.38, -0.45], 0x8C6239),
                cyl(0.08, 0.74, [-0.8, 0.38, 0.45], 0x8C6239),
                cyl(0.08, 0.74, [0.8, 0.38, 0.45], 0x8C6239),
            ]
        case .fridge:
            return [
                box([1.25, 2.15, 1.0], [0, 1.1, 0], 0xF7F4EF),
                box([1.28, 0.06, 0.04], [0, 1.35, 0.5], 0xD5D0C8),
                box([0.08, 0.7, 0.08], [0.42, 0.85, 0.52], 0xC5C9D1),
                box([1.1, 0.7, 0.04], [0, 1.7, 0.5], 0xE7F6F4),
            ]
        case .ball:
            return [
                sphere(0.9, [0, 0.9, 0], 0xFF5D73),
                cyl(0.92, 0.08, [0, 0.9, 0], 0xFFF3F5, spin: .pi / 2, axis: [0, 0, 1]),
            ]
        case .frisbee:
            return [cyl(1.0, 0.08, [0, 0.08, 0], 0xFFD23F)]
        case .gnome:
            return [
                cyl(0.42, 0.55, [0, 0.32, 0], 0x3D7EA6),
                sphere(0.32, [0, 0.82, 0], 0xF2C2A5),
                cone(0.4, 0.55, [0, 1.28, 0], 0xE23B3B),
                sphere(0.08, [0, 0.84, 0.28], 0xE07A5F),
            ]
        case .wateringCan:
            return [
                cyl(0.48, 0.6, [0, 0.4, 0], 0x4DA3FF),
                cone(0.14, 0.55, [0.55, 0.55, 0], 0x4DA3FF, spin: .pi / 2, axis: [0, 0, 1]),
                box([0.1, 0.4, 0.1], [-0.5, 0.6, 0], 0x2E6FB3),
            ]
        case .planter:
            return [
                cone(0.72, 0.6, [0, 0.36, 0], 0xE07A3D),
                sphere(0.38, [0, 0.85, 0], 0x3FA34D),
                sphere(0.28, [0.28, 0.78, 0.1], 0x7ED36A),
                sphere(0.22, [-0.22, 0.75, -0.05], 0x2E8B57),
            ]
        case .grill:
            return [
                box([1.3, 0.38, 0.75], [0, 0.78, 0], 0x3A3D5C),
                cyl(0.55, 0.22, [0, 1.05, 0], 0x2E3148),
                box([0.45, 0.08, 0.08], [0.85, 0.95, 0], 0xC0C6D4),
                cyl(0.07, 0.7, [-0.5, 0.36, -0.28], 0x2A2C3E),
                cyl(0.07, 0.7, [0.5, 0.36, -0.28], 0x2A2C3E),
                cyl(0.07, 0.7, [-0.5, 0.36, 0.28], 0x2A2C3E),
                cyl(0.07, 0.7, [0.5, 0.36, 0.28], 0x2A2C3E),
            ]
        case .bike:
            return [
                cyl(0.42, 0.1, [-0.7, 0.42, 0], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
                cyl(0.42, 0.1, [0.7, 0.42, 0], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
                box([1.3, 0.08, 0.08], [0, 0.55, 0], 0x2EC4B6),
                box([0.08, 0.55, 0.08], [0.35, 0.85, 0], 0x2EC4B6),
                box([0.35, 0.08, 0.08], [0.5, 1.12, 0], 0xF25C54),
            ]
        case .doghouse:
            return [
                box([1.35, 0.9, 1.15], [0, 0.5, 0], 0xF25C54),
                box([1.55, 0.16, 1.35], [0.15, 1.05, 0], 0x8C3A2F, spin: 0.45, axis: [0, 0, 1]),
                box([1.55, 0.16, 1.35], [-0.15, 1.05, 0], 0x8C3A2F, spin: -0.45, axis: [0, 0, 1]),
                box([0.4, 0.5, 0.06], [0, 0.32, 0.58], 0x2B2118),
            ]
        case .cone:
            return [
                cone(0.55, 1.15, [0, 0.62, 0], 0xFF7A1A),
                cyl(0.58, 0.1, [0, 0.08, 0], 0xF4F1EA),
                cyl(0.28, 0.08, [0, 0.55, 0], 0xF4F1EA),
            ]
        case .hydrant:
            return [
                cyl(0.28, 0.7, [0, 0.45, 0], 0xE23B3B),
                cyl(0.34, 0.16, [0, 0.88, 0], 0xC43131),
                sphere(0.14, [0, 1.05, 0], 0xF4F1EA),
                cyl(0.1, 0.28, [0.32, 0.62, 0], 0xC43131, spin: .pi / 2, axis: [0, 0, 1]),
            ]
        case .trashCan:
            return [
                cyl(0.55, 0.95, [0, 0.5, 0], 0x6B7280),
                cyl(0.6, 0.1, [0, 1.0, 0], 0x4B5563),
            ]
        case .bench:
            return [
                box([1.7, 0.12, 0.55], [0, 0.48, 0], 0xC47A4A),
                box([1.7, 0.5, 0.1], [0, 0.78, -0.22], 0xC47A4A),
                box([0.1, 0.45, 0.4], [-0.7, 0.24, 0], 0x6B5344),
                box([0.1, 0.45, 0.4], [0.7, 0.24, 0], 0x6B5344),
            ]
        case .car:
            return [
                box([1.9, 0.4, 0.9], [0, 0.42, 0], 0x4C7CFF),
                box([0.9, 0.38, 0.82], [-0.1, 0.78, 0], 0xD7E6FF),
                cyl(0.22, 0.12, [-0.6, 0.22, 0.42], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
                cyl(0.22, 0.12, [0.6, 0.22, 0.42], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
                cyl(0.22, 0.12, [-0.6, 0.22, -0.42], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
                cyl(0.22, 0.12, [0.6, 0.22, -0.42], 0x2B2E38, spin: .pi / 2, axis: [0, 0, 1]),
            ]
        case .tree:
            return [
                cyl(0.2, 0.85, [0, 0.45, 0], 0x8B5A34),
                sphere(0.85, [0, 1.35, 0], 0x3CB371),
                sphere(0.45, [0.4, 1.15, 0.2], 0x2E9B5A),
            ]
        case .kiosk:
            return [
                box([1.2, 1.25, 0.95], [0, 0.7, 0], 0xF4EFE6),
                box([1.7, 0.12, 1.15], [0, 1.45, 0.15], 0xFF6B6B),
                box([0.7, 0.35, 0.06], [0, 1.05, 0.5], 0xFFE08A),
            ]
        case .building:
            return [
                box([1.45, 2.5, 1.2], [0, 1.28, 0], 0xF6D58B),
                box([1.55, 0.18, 1.3], [0, 2.58, 0], 0xE07A5F),
                box([0.28, 0.32, 0.06], [-0.38, 1.7, 0.62], 0x8ECAE6),
                box([0.28, 0.32, 0.06], [0.38, 1.7, 0.62], 0x8ECAE6),
                box([0.28, 0.32, 0.06], [-0.38, 1.1, 0.62], 0x8ECAE6),
                box([0.28, 0.32, 0.06], [0.38, 1.1, 0.62], 0x8ECAE6),
                box([0.4, 0.6, 0.06], [0, 0.4, 0.62], 0x6B4F3A),
            ]
        }
    }
}
