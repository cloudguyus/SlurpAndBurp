import RealityKit
import simd
#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
typealias PlatformColor = NSColor
#endif

/// Flat colors for the low-poly props. Nothing is shaded, so a level reads the same
/// on a phone and a Mac without a light rig.
@MainActor
enum Paint {
    static func color(_ hex: UInt32) -> PlatformColor {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        return PlatformColor(red: red, green: green, blue: blue, alpha: 1)
    }

    static func unlit(_ hex: UInt32) -> UnlitMaterial {
        UnlitMaterial(color: color(hex))
    }
}

@MainActor
enum Meshes {
    static func entity(_ bit: Bit) -> ModelEntity {
        let mesh: MeshResource
        switch bit.form {
        case .box:
            mesh = .generateBox(size: bit.size, cornerRadius: 0)
        case .sphere:
            mesh = .generateSphere(radius: max(0.02, bit.size.x))
        case .cylinder:
            mesh = .generateCylinder(height: max(0.02, bit.size.y), radius: max(0.02, bit.size.x))
        case .cone:
            mesh = .generateCone(height: max(0.02, bit.size.y), radius: max(0.02, bit.size.x))
        }
        let model = ModelEntity(mesh: mesh, materials: [Paint.unlit(bit.hex)])
        model.position = bit.position
        if abs(bit.spin) > 0.001 {
            let length = simd_length(bit.axis)
            let axis = length > 0.0001 ? bit.axis / length : SIMD3<Float>(0, 1, 0)
            model.orientation = simd_quatf(angle: bit.spin, axis: axis)
        }
        return model
    }
}

struct Bit {
    enum Form { case box, sphere, cylinder, cone }
    var form: Form
    var size: SIMD3<Float>
    var position: SIMD3<Float>
    var spin: Float = 0
    var axis: SIMD3<Float> = [0, 1, 0]
    var hex: UInt32
}

func box(_ size: SIMD3<Float>, _ position: SIMD3<Float>, _ hex: UInt32, spin: Float = 0, axis: SIMD3<Float> = [0, 1, 0]) -> Bit {
    Bit(form: .box, size: size, position: position, spin: spin, axis: axis, hex: hex)
}

func sphere(_ radius: Float, _ position: SIMD3<Float>, _ hex: UInt32) -> Bit {
    Bit(form: .sphere, size: [radius, radius, radius], position: position, hex: hex)
}

func cyl(_ radius: Float, _ height: Float, _ position: SIMD3<Float>, _ hex: UInt32, spin: Float = 0, axis: SIMD3<Float> = [1, 0, 0]) -> Bit {
    Bit(form: .cylinder, size: [radius, height, radius], position: position, spin: spin, axis: axis, hex: hex)
}

func cone(_ radius: Float, _ height: Float, _ position: SIMD3<Float>, _ hex: UInt32, spin: Float = 0, axis: SIMD3<Float> = [0, 1, 0]) -> Bit {
    Bit(form: .cone, size: [radius, height, radius], position: position, spin: spin, axis: axis, hex: hex)
}
